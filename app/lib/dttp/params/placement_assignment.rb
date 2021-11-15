# frozen_string_literal: true

module Dttp
  module Params
    class PlacementAssignment
      include Mappable

      ACADEMIC_YEAR_2020_2021 = "76bcaeca-2bd1-e711-80df-005056ac45bb"
      ACADEMIC_YEAR_2021_2022 = "21196925-17b9-e911-a863-000d3ab0dc71"
      ACADEMIC_YEAR_2022_2023 = "ed0db9f4-eff5-eb11-94ef-000d3ab1e900"

      SCHOOL_NOT_APPLICABLE = "9e7fcac0-4a37-e811-80ef-005056ac45bb"

      COURSE_LEVEL_PG = 12
      COURSE_LEVEL_UG = 20

      ITT_QUALIFICATION_AIM_QTS = "68cbae32-7389-e711-80d8-005056ac45bb"

      SCHOLARSHIP = "188375c2-7722-e711-80c8-0050568902d3"

      ALLOCATED_PLACE = 1
      NO_ALLOCATED_PLACE = 2

      attr_reader :trainee, :qualifying_degree, :params

      def initialize(trainee, contact_change_set_id = nil)
        @trainee = trainee
        @qualifying_degree = trainee.degrees.order(:created_at).first # assuming first is most relevant - TBC
        @params = build_params

        if contact_change_set_id
          @params.merge!({
            "dfe_ContactId@odata.bind" => "$#{contact_change_set_id}",
          })
        end
      end

      def to_json(*_args)
        params.to_json
      end

    private

      def build_params
        {
          "dfe_RouteId@odata.bind" => "/dfe_routes(#{dttp_route_id(training_route)})",
          "dfe_CoursePhaseId@odata.bind" => "/dfe_coursephases(#{course_phase_id(trainee.course_age_range)})",
          "dfe_programmestartdate" => trainee.course_start_date.in_time_zone.iso8601,
          "dfe_programmeenddate" => trainee.course_end_date.in_time_zone.iso8601,
          "dfe_traineeid" => trainee.trainee_id || "NOTPROVIDED",
          "dfe_AcademicYearId@odata.bind" => "/dfe_academicyears(#{academic_year})",
          "dfe_courselevel" => course_level,
          "dfe_sendforregistration" => true,
          "dfe_ProviderId@odata.bind" => "/accounts(#{trainee.provider.dttp_id})",
          "dfe_ITTQualificationAimId@odata.bind" => "/dfe_ittqualificationaims(#{dttp_qualification_aim_id(trainee.training_route)})",
          "dfe_programmeyear" => 1,
          "dfe_programmelength" => 1,
          "dfe_ebacc" => trainee.ebacc,
        }
        .merge(commencement_date_params)
        .merge(degree_params)
        .merge(school_params)
        .merge(subject_params)
        .merge(study_mode_params)
        .merge(training_initiative_params)
        .merge(funding_params)
        .merge(region_params)
      end

      def course_level
        if trainee.undergrad_route?
          COURSE_LEVEL_UG
        else
          COURSE_LEVEL_PG
        end
      end

      def uk_specific_params
        {
          "dfe_AwardingInstitutionId@odata.bind" => "/accounts(#{degree_institution_id(qualifying_degree.institution)})",
          "dfe_ClassofUGDegreeId@odata.bind" => "/dfe_classofdegrees(#{degree_class_id(qualifying_degree.grade)})",
        }
      end

      def commencement_date_params
        return {} unless trainee.commencement_date

        {
          "dfe_commencementdate" => trainee.commencement_date.in_time_zone.iso8601,
        }
      end

      def degree_params
        return {} unless trainee.requires_degree?

        {
          "dfe_SubjectofUGDegreeId@odata.bind" => "/dfe_jacses(#{degree_subject_id(qualifying_degree.subject)})",
          "dfe_undergraddegreedateobtained" => Date.parse("01-01-#{trainee.degrees.first.graduation_year}").to_datetime.iso8601,
        }
        .merge(qualifying_degree.uk? ? uk_specific_params : non_uk_specific_params)
      end

      def non_uk_specific_params
        {
          "dfe_CountryofStudyId@odata.bind" => "/dfe_countries(#{degree_country_id(qualifying_degree.country)})",
        }
      end

      def school_params
        return {} unless trainee.requires_schools?

        params = { "dfe_LeadSchoolId@odata.bind" => "/accounts(#{lead_school_id})" }

        if trainee.requires_employing_school?
          params.merge!("dfe_EmployingSchoolId@odata.bind" => "/accounts(#{employing_school_id})")
        end

        params
      end

      def lead_school_id
        trainee.lead_school_not_applicable? ? SCHOOL_NOT_APPLICABLE : dttp_school_id(trainee.lead_school.urn)
      end

      def employing_school_id
        trainee.employing_school_not_applicable? ? SCHOOL_NOT_APPLICABLE : dttp_school_id(trainee.employing_school.urn)
      end

      def subject_params
        first_subject.merge(second_subject, third_subject).compact
      end

      def first_subject
        { "dfe_ITTSubject1Id@odata.bind" => "/dfe_subjects(#{course_subject_id(trainee.course_subject_one)})" }
      end

      def second_subject
        return {} if trainee.course_subject_two.blank?

        { "dfe_ITTSubject2Id@odata.bind" => "/dfe_subjects(#{course_subject_id(trainee.course_subject_two)})" }
      end

      def third_subject
        return {} if trainee.course_subject_three.blank?

        { "dfe_ITTSubject3Id@odata.bind" => "/dfe_subjects(#{course_subject_id(trainee.course_subject_three)})" }
      end

      def training_initiative_params
        return {} unless dttp_recognised_initiative?

        {
          "dfe_Initiative1Id@odata.bind" => "/dfe_initiatives(#{training_initiative_id(trainee.training_initiative)})",
        }
      end

      def funding_params
        if applying_for_funding?
          return {
            "dfe_allocatedplace" => ALLOCATED_PLACE,
            "dfe_BursaryDetailsId@odata.bind" => "/dfe_bursarydetails(#{funding_details_id})",
          }
        end

        { "dfe_allocatedplace" => NO_ALLOCATED_PLACE }
      end

      def applying_for_funding?
        trainee.applying_for_bursary || trainee.applying_for_grant || trainee.applying_for_scholarship
      end

      def funding_details_id
        return SCHOLARSHIP if trainee.applying_for_scholarship

        bursary_details_id(trainee.bursary_tier.presence || trainee.training_route)
      end

      def region_params
        return {} unless trainee.hpitt_provider?

        {
          "dfe_GovernmentOfficeRegionId@odata.bind" => "/dfe_goregions(#{region_id(trainee.region)})",
        }
      end

      def study_mode_params
        return {} if trainee.study_mode.blank?

        {
          "dfe_StudyModeId@odata.bind" => "/dfe_studymodeses(#{course_study_mode_id(trainee.study_mode)})",
        }
      end

      def academic_year
        return ACADEMIC_YEAR_2020_2021 if trainee.course_start_date.between?(Date.parse("1/8/2020"), Date.parse("31/7/2021"))
        return ACADEMIC_YEAR_2021_2022 if trainee.course_start_date.between?(Date.parse("1/8/2021"), Date.parse("31/7/2022"))

        ACADEMIC_YEAR_2022_2023 if trainee.course_start_date.between?(Date.parse("1/8/2022"), Date.parse("31/7/2023"))
      end

      def training_route
        return trainee.training_initiative if trainee.future_teaching_scholars?

        trainee.training_route
      end

      def dttp_recognised_initiative?
        [
          ROUTE_INITIATIVES_ENUMS[:transition_to_teach],
          ROUTE_INITIATIVES_ENUMS[:troops_to_teachers],
          ROUTE_INITIATIVES_ENUMS[:now_teach],
          ROUTE_INITIATIVES_ENUMS[:maths_physics_chairs_programme_researchers_in_schools],
        ].include?(trainee.training_initiative)
      end
    end
  end
end
