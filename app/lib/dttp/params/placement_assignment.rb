# frozen_string_literal: true

module Dttp
  module Params
    class PlacementAssignment
      include Mappable

      ACADEMIC_YEAR_2020_2021 = "76bcaeca-2bd1-e711-80df-005056ac45bb"
      ACADEMIC_YEAR_2021_2022 = "21196925-17b9-e911-a863-000d3ab0dc71"
      ACADEMIC_YEAR_2022_2023 = "ed0db9f4-eff5-eb11-94ef-000d3ab1e900"

      COURSE_LEVEL_PG = 12
      COURSE_LEVEL_UG = 20
      ITT_QUALIFICATION_AIM_QTS = "68cbae32-7389-e711-80d8-005056ac45bb"

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
            "dfe_RouteId@odata.bind" => "/dfe_routes(#{dttp_route_id(training_route)})",
          })
        end
      end

      def to_json(*_args)
        params.to_json
      end

    private

      def build_params
        {
          "dfe_CoursePhaseId@odata.bind" => "/dfe_coursephases(#{course_phase_id(trainee.course_age_range)})",
          "dfe_SubjectofUGDegreeId@odata.bind" => "/dfe_jacses(#{degree_subject_id(qualifying_degree.subject)})",
          "dfe_programmestartdate" => trainee.course_start_date.in_time_zone.iso8601,
          "dfe_programmeenddate" => trainee.course_end_date.in_time_zone.iso8601,
          "dfe_commencementdate" => trainee.commencement_date.in_time_zone.iso8601,
          "dfe_traineeid" => trainee.trainee_id || "NOTPROVIDED",
          "dfe_AcademicYearId@odata.bind" => "/dfe_academicyears(#{academic_year})",
          "dfe_courselevel" => course_level,
          "dfe_sendforregistration" => true,
          "dfe_ProviderId@odata.bind" => "/accounts(#{trainee.provider.dttp_id})",
          "dfe_ITTQualificationAimId@odata.bind" => "/dfe_ittqualificationaims(#{dttp_qualification_aim_id(trainee.training_route)})",
          "dfe_programmeyear" => 1, # TODO: this will need to be derived for other routes. It's n of x year course e.g. 1 of 2
          "dfe_programmelength" => 1, # TODO: this will change for other routes as above. So these two are course_year of course_length
          "dfe_undergraddegreedateobtained" => Date.parse("01-01-#{trainee.degrees.first.graduation_year}").to_datetime.iso8601,
        }
        .merge(qualifying_degree.uk? ? uk_specific_params : non_uk_specific_params)
        .merge(school_params)
        .merge(subject_params)
        .merge(study_mode_params)
        .merge(training_initiative_params)
        .merge(bursary_params)
      end

      def course_level
        if trainee.training_route == "early_years_undergrad"
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

      def non_uk_specific_params
        {
          "dfe_CountryofStudyId@odata.bind" => "/dfe_countries(#{degree_country_id(qualifying_degree.country)})",
        }
      end

      def school_params
        return {} unless trainee.requires_schools?

        params = { "dfe_LeadSchoolId@odata.bind" => "/accounts(#{dttp_school_id(trainee.lead_school.urn)})" }

        if trainee.requires_employing_school?
          params.merge!("dfe_EmployingSchoolId@odata.bind" => "/accounts(#{dttp_school_id(trainee.employing_school.urn)})")
        end

        params
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
        return {} unless send_funding_to_dttp? && dttp_recognised_initiative?

        {
          "dfe_Initiative1Id@odata.bind" => "/dfe_initiatives(#{training_initiative_id(trainee.training_initiative)})",
        }
      end

      def bursary_params
        return {} unless send_funding_to_dttp?
        return { "dfe_allocatedplace" => NO_ALLOCATED_PLACE } unless trainee.applying_for_bursary

        { "dfe_allocatedplace" => ALLOCATED_PLACE }.merge(bursary_details_params)
      end

      def bursary_details_params
        if trainee.bursary_tier.present?
          {
            "dfe_ITTFundingBandId@odata.bind" => "/dfe_ittfundingbands(#{funding_bands_id(trainee.bursary_tier)})",
          }
        else
          {
            "dfe_BursaryDetailsId@odata.bind" => "/dfe_bursarydetails(#{bursary_details_id(trainee.training_route)})",
          }
        end
      end

      def study_mode_params
        return {} if trainee.study_mode.blank?

        {
          "dfe_StudyModeId@odata.bind" => "/dfe_studymodeses(#{course_study_mode_id(trainee.study_mode)})",
        }
      end

      def send_funding_to_dttp?
        FeatureService.enabled?(:show_funding) && FeatureService.enabled?(:send_funding_to_dttp)
      end

      def academic_year
        return ACADEMIC_YEAR_2020_2021 if trainee.course_start_date.between?(Date.parse("1/8/2020"), Date.parse("31/7/2021"))
        return ACADEMIC_YEAR_2021_2022 if trainee.course_start_date.between?(Date.parse("1/8/2021"), Date.parse("31/7/2022"))
        return ACADEMIC_YEAR_2022_2023 if trainee.course_start_date.between?(Date.parse("1/8/2022"), Date.parse("31/7/2023"))
      end

      def training_route
        return trainee.training_initiative if trainee.future_teaching_scholars?

        trainee.training_route
      end

      def dttp_recognised_initiative?
        [
          ROUTE_INITIATIVES_ENUMS[:transition_to_teach],
          ROUTE_INITIATIVES_ENUMS[:now_teach],
          ROUTE_INITIATIVES_ENUMS[:maths_physics_chairs_programme_researchers_in_schools],
        ].include?(trainee.training_initiative)
      end
    end
  end
end
