# frozen_string_literal: true

module Dttp
  module Params
    class DegreeQualification
      include Mappable

      attr_reader :degree, :contact_change_set_id, :placement_assignment_change_set_id, :params

      def initialize(degree, contact_change_set_id, placement_assignment_change_set_id)
        @degree = degree
        @contact_change_set_id = contact_change_set_id
        @placement_assignment_change_set_id = placement_assignment_change_set_id
        @params = build_parms
      end

      def to_json(*_args)
        params.to_json
      end

    private

      def build_parms
        {
          "dfe_ContactId@odata.bind" => "$#{contact_change_set_id}",
          "dfe_TrainingRecordId@odata.bind" => "$#{placement_assignment_change_set_id}",
          "dfe_DegreeSubjectId@odata.bind" => "/dfe_jacses(#{degree_subject_id(degree.subject)})",
        }.merge(degree.uk? ? uk_specific_params : non_uk_specific_params)
      end

      def uk_specific_params
        {
          "dfe_name" => degree.uk_degree,
          "dfe_ClassofDegreeId@odata.bind" => "/dfe_classofdegrees(#{degree_class_id(degree.grade)})",
          "dfe_DegreeTypeId@odata.bind" => "/dfe_degreetypes(#{degree_type_id(degree.uk_degree)})",
          "dfe_AwardingInstitutionId@odata.bind" => "/accounts(#{degree_institution_id(degree.institution)})",
        }
      end

      def non_uk_specific_params
        degree_type = degree.non_uk_degree_non_enic? ? "Unknown" : "Degree equivalent"

        {
          "dfe_name" => degree.non_uk_degree,
          "dfe_DegreeTypeId@odata.bind" => "/dfe_degreetypes(#{degree_type_id(degree_type)})",
          "dfe_DegreeCountryId@odata.bind" => "/dfe_countries(#{degree_country_id(degree.country)})",
        }
      end
    end
  end
end
