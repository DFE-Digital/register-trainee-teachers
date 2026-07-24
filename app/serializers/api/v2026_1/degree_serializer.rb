# frozen_string_literal: true

module Api
  module V20261
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
        ::ReferenceData::DEGREE_SUBJECTS.hesa_code_for(@degree.subject)
      end

      def institution
        ::ReferenceData::INSTITUTIONS.hesa_code_for(@degree.institution)
      end

      def country
        ::ReferenceData::COUNTRIES.hesa_code_for(@degree.country)
      end

      def uk_degree
        ::ReferenceData::DEGREE_TYPES.hesa_code_for(@degree.uk_degree)
      end

      def non_uk_degree
        ::ReferenceData::DEGREE_TYPES.hesa_code_for(@degree.non_uk_degree)
      end

      def grade
        ::ReferenceData::DEGREE_GRADES.hesa_code_for(@degree.grade)
      end
    end
  end
end
