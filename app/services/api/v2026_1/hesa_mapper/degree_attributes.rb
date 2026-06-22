# frozen_string_literal: true

module Api
  module V20261
    module HesaMapper
      class DegreeAttributes
        include ServicePattern

        INSTITUTE_OF_EDUCATION_HESA_CODE = "0133"
        UNIVERSITY_COLLEGE_LONDON_HESA_CODE = "0149"
        PASS_WITHOUT_HONOURS_HESA_CODE = "09"
        NEAREST_EQUIVALENT_GRADE_HESA_CODE = "14"
        OTHER_UK_INSTITUTION_NAME = "other_uk_institution"

        ATTRIBUTES = %i[
          country
          grade
          uk_degree
          non_uk_degree
          subject
          institution
          graduation_year
          other_grade
        ].freeze

        def initialize(params)
          @params = params
        end

        def call
          mapped_params
        end

      private

        def mapped_params
          {
            country:,
            grade:,
            grade_uuid:,
            uk_degree:,
            uk_degree_uuid:,
            non_uk_degree:,
            subject:,
            subject_uuid:,
            institution:,
            institution_uuid:,
            graduation_year:,
            locale_code:,
            other_grade:,
          }
        end

        def subject
          reference_subject&.display_name
        end

        def subject_uuid
          reference_subject&.id
        end

        def graduation_year
          year = @params[:graduation_year]

          if valid_date?(year)
            year.to_date.year
          else
            year
          end
        end

        def institution
          return unless uk_country_or_uk_institution_present?

          find_institution&.display_name
        end

        def institution_uuid
          return unless uk_country_or_uk_institution_present?

          find_institution&.id
        end

        def locale_code
          uk_country_or_uk_institution_present? ? "uk" : "non_uk"
        end

        def country
          uk_country_or_uk_institution_present? ? nil : country_from_mapping
        end

        def uk_degree
          return Api::V20261::HesaMapper::Attributes::InvalidValue.new(@params[:uk_degree]) if @params[:uk_degree].present? && uk_degree_type.blank?

          uk_degree_type&.display_name
        end

        def uk_degree_uuid
          return unless uk_country_or_uk_institution_present?

          uk_degree_type&.id
        end

        def non_uk_degree
          return Api::V20261::HesaMapper::Attributes::InvalidValue.new(@params[:non_uk_degree]) if @params[:non_uk_degree].present? && non_uk_degree_type.blank?

          non_uk_degree_type&.display_name
        end

        def grade
          grade_from_hesa_code&.display_name
        end

        def grade_uuid
          grade_from_hesa_code&.id
        end

        def other_grade
          @params[:other_grade] if grade == "Other"
        end

        def reference_subject
          ::ReferenceData::DEGREE_SUBJECTS.find_by_hesa_code(@params[:subject])
        end

        def find_institution
          ::ReferenceData::INSTITUTIONS.find_by_hesa_code(institution_hesa_code) ||
            ::ReferenceData::INSTITUTIONS.find(OTHER_UK_INSTITUTION_NAME)
        end

        def institution_hesa_code
          if @params[:institution] == INSTITUTE_OF_EDUCATION_HESA_CODE
            UNIVERSITY_COLLEGE_LONDON_HESA_CODE
          else
            @params[:institution]
          end
        end

        def uk_country?
          country_from_mapping.nil? || Hesa::CodeSets::Countries::UK_COUNTRIES.include?(country_from_mapping)
        end

        def uk_country_or_uk_institution_present?
          uk_country? || institution_hesa_code.present?
        end

        def country_from_mapping
          @country_from_mapping ||= begin
            mapped_value = ::ReferenceData::COUNTRIES.find_by_hesa_code(@params[:country])&.display_name

            if @params[:country].present? && mapped_value.nil?
              Api::V20261::HesaMapper::Attributes::InvalidValue.new(@params[:country])
            else
              mapped_value
            end
          end
        end

        def uk_degree_type
          @uk_degree_type ||= ::ReferenceData::DEGREE_TYPES.find_by_hesa_code(@params[:uk_degree])
        end

        def non_uk_degree_type
          @non_uk_degree_type ||= ::ReferenceData::DEGREE_TYPES.find_by_hesa_code(@params[:non_uk_degree])
        end

        def grade_from_hesa_code
          @grade_from_hesa_code ||= ::ReferenceData::DEGREE_GRADES.find_by_hesa_code(grade_hesa_code)
        end

        def grade_hesa_code
          if @params[:grade] == PASS_WITHOUT_HONOURS_HESA_CODE
            NEAREST_EQUIVALENT_GRADE_HESA_CODE
          else
            @params[:grade]
          end
        end

        def valid_date?(date)
          return false unless date.is_a?(String)

          Date.strptime(date, "%Y-%m-%d")
          true
        rescue ArgumentError
          false
        end
      end
    end
  end
end
