# frozen_string_literal: true

module Dttp
  module Params
    class PlacementAssignment
      include Mappable

      ASSESSMENT_ONLY_DTTP_ID = "99f435d5-a626-e711-80c8-0050568902d3"
      ACADEMIC_YEAR_2020_2021 = "76bcaeca-2bd1-e711-80df-005056ac45bb"

      attr_reader :trainee, :qualifying_degree, :params

      def initialize(trainee, contact_change_set_id = nil)
        @trainee = trainee
        @qualifying_degree = trainee.degrees.order(:created_at).first # assuming first is most relevant - TBC
        @params = build_parms

        if contact_change_set_id
          @params.merge!({
            "dfe_ContactId@odata.bind" => "$#{contact_change_set_id}",
            "dfe_sendforregistrationdate" => Time.zone.now.iso8601,
            "dfe_RouteId@odata.bind" => "/dfe_routes(#{ASSESSMENT_ONLY_DTTP_ID})",
          })
        end
      end

      def to_json(*_args)
        params.to_json
      end

    private

      def build_parms
        {
          "dfe_CoursePhaseId@odata.bind" => "/dfe_coursephases(#{course_phase_id(trainee.age_range)})",
          "dfe_ITTSubject1Id@odata.bind" => "/dfe_subjects(#{programme_subject_id(trainee.subject)})",
          "dfe_SubjectofUGDegreeId@odata.bind" => "/dfe_jacses(#{degree_subject_id(qualifying_degree.subject)})",
          "dfe_programmestartdate" => trainee.programme_start_date.in_time_zone.iso8601,
          "dfe_programmeenddate" => trainee.programme_end_date.in_time_zone.iso8601,
          "dfe_traineeid" => trainee.trainee_id || "NOTPROVIDED",
          "dfe_AcademicYearId@odata.bind" => "/dfe_academicyears(#{ACADEMIC_YEAR_2020_2021})",
          "dfe_sendforsiregistration" => true,
          "dfe_ProviderId@odata.bind" => "/accounts(#{trainee.provider.dttp_id})",
        }.merge(qualifying_degree.uk? ? uk_specific_params : non_uk_specific_params)
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
    end
  end
end
