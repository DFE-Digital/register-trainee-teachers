# frozen_string_literal: true

module Api
  module MapHesaAttributes
    module Degrees
      class V01
        ATTRIBUTES = %i[graduation_date subject_one].freeze
        INSTITUTE_OF_EDUCATION_HESA_CODE = "0133"
        UNIVERSITY_COLLEGE_LONDON_HESA_CODE = "0149"
        PASS_WITHOUT_HONOURS_HESA_CODE = "09"
        NEAREST_EQUIVALENT_GRADE_HESA_CODE = "14"
        HONOURS_TO_NON_HONOURS_HESA_CODE_MAP = {
          "002" => "001",
          "004" => "003",
          "006" => "005",
          "008" => "007",
          "010" => "009",
          "014" => "012",
        }.freeze

        def initialize(params)
          @params = params
        end

        def call
          {
            subject:,
            subject_uuid:,
            graduation_year:,
            institution:,
            institution_uuid:,
            locale_code:,
            country:,
            uk_degree:,
            uk_degree_uuid:,
            non_uk_degree:,
            grade:,
            grade_uuid:,
          }
        end

        def subject
          def_reference_subject&.name
        end

        def subject_uuid
          def_reference_subject&.id
        end

        def graduation_year
          @params[:graduation_date]&.to_date&.year
        end

        def institution
          return unless uk_country_or_uk_institution_present?

          find_institution&.name
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
          return unless uk_country_or_uk_institution_present?

          degree_type&.name
        end

        def uk_degree_uuid
          return unless uk_country_or_uk_institution_present?

          degree_type&.id
        end

        def non_uk_degree
          return if uk_country_or_uk_institution_present?

          degree_type&.name
        end

        def grade
          grade_from_hesa_code&.name
        end

        def grade_uuid
          grade_from_hesa_code&.id
        end

      private

        def def_reference_subject
          DfEReference::DegreesQuery.find_subject(hecos_code: @params[:subject_one])
        end

        def find_institution
          hesa_code = institution_hesa_code
          institution = DfEReference::DegreesQuery.find_institution(hesa_code:)

          institution || DfEReference::DegreesQuery.find_institution(name: "Other UK institution")
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
          @country_from_mapping ||= Hesa::CodeSets::Countries::MAPPING[@params[:country]]
        end

        def degree_type
          hesa_code = HONOURS_TO_NON_HONOURS_HESA_CODE_MAP[@params[:degree_type]] || @params[:degree_type]
          @degree_type = DfEReference::DegreesQuery.find_type(hesa_code:)
        end

        def grade_from_hesa_code
          @grade_from_hesa_code ||= DfEReference::DegreesQuery.find_grade(hesa_code: grade_hesa_code)
        end

        def grade_hesa_code
          if @params[:grade] == PASS_WITHOUT_HONOURS_HESA_CODE
            NEAREST_EQUIVALENT_GRADE_HESA_CODE
          else
            @params[:grade]
          end
        end
      end
    end
  end
end
