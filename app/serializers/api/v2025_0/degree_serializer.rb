# frozen_string_literal: true

module Api
  module V20250
    class DegreeSerializer
      EXCLUDED_ATTRIBUTES = %w[
        id
        slug
        trainee_id
        dttp_id
        locale_code
      ].freeze

      def initialize(degree)
        @degree = degree
      end

      def as_hash
        @degree.attributes
          .except(*EXCLUDED_ATTRIBUTES)
          .with_indifferent_access.merge({
            degree_id:,
            subject:,
            institution:,
            country:,
            uk_degree:,
            non_uk_degree:,
            grade:,
          })
      end

      def degree_id
        @degree.slug
      end

      def subject
        subjects = DfEReference::DegreesQuery::SUBJECTS.constituent_lists.first.all_as_hash
        subject = subjects.find { |_, item| item[:name] == @degree.subject }&.last
        return if subject.blank?

        subject[:hecos_code]
      end

      def institution
        institutions = DfEReference::DegreesQuery::INSTITUTIONS.constituent_lists.first.all_as_hash
        institution = institutions.find { |_, item| item[:name] == @degree.institution }&.last
        return if institution.blank?

        institution[:hesa_itt_code]
      end

      def country
        Hesa::CodeSets::Countries::MAPPING.key(@degree.country)
      end

      def uk_degree
        types = DfE::ReferenceData::Degrees::TYPES.all_as_hash
        matching_type = types.find { |_, item| item[:name] == @degree.uk_degree }&.last

        return if matching_type.blank?

        matching_type[:hesa_itt_code]
      end

      def non_uk_degree
        matching_type = DfE::ReferenceData::Degrees::TYPES.all.detect { |type| type[:name] == @degree.non_uk_degree }

        return if matching_type.blank?

        matching_type[:hesa_itt_code]
      end

      def grade
        grades = DfE::ReferenceData::Degrees::GRADES.all_as_hash
        matching_grade = grades.find { |_, item| item[:name] == @degree.grade }&.last
        return if matching_grade.blank?

        matching_grade[:hesa_code]
      end
    end
  end
end
