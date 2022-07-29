# frozen_string_literal: true

module Degrees
  class DfeReference
    OTHER = "Other"

    COMMON_TYPES = ["Bachelor of Arts", "Bachelor of Science", "Master of Arts", "PhD"].freeze

    SUPPORTED_GRADES_BY_HESA_CODES = %w[1 2 3 5 14].freeze

    SUPPORTED_GRADES = DfE::ReferenceData::Degrees::GRADES.all_as_hash.select { |_, item|
      SUPPORTED_GRADES_BY_HESA_CODES.include?(item[:hesa_code])
    }

    GRADES = DfE::ReferenceData::HardcodedReferenceList.new(
      SUPPORTED_GRADES.merge(
        {
          "4182ef37-df1c-4f1e-9be6-feb66037f775" => {
            name: OTHER,
            match_synonyms: [],
            suggestion_synonyms: [],
          },
        },
      ),
    )

    INSTITUTIONS = DfE::ReferenceData::TweakedReferenceList.new(
      DfE::ReferenceData::Degrees::INSTITUTIONS,
      DfE::ReferenceData::Record.new(
        {
          "96e9359f-dbad-4486-8de9-f05f3c7104c2" => {
            name: OTHER,
            match_synonyms: [],
            suggestion_synonyms: [],
            abbreviation: nil,
          },
        },
      ),
    )

    SUBJECTS = DfE::ReferenceData::Degrees::SINGLE_SUBJECTS
    TYPES = DfE::ReferenceData::Degrees::TYPES_INCLUDING_GENERICS

    class << self
      def find_subject(uuid: nil, name: nil, hecos_code: nil)
        find_item(:single_subjects, id: uuid, hecos_code: hecos_code, name: name)
      end

      def find_type(uuid: nil, name: nil, abbreviation: nil, hesa_code: nil)
        find_item(:types_including_generics,
                  id: uuid,
                  name: name,
                  hesa_itt_code: hesa_code,
                  abbreviation: abbreviation)
      end

      def find_institution(uuid: nil, name: nil, hesa_code: nil)
        find_item(:institutions, id: uuid, hesa_itt_code: hesa_code, name: name)
      end

      def find_grade(uuid: nil, name: nil, hesa_code: nil)
        find_item(:grades, id: uuid, hesa_code: hesa_code, name: name)
      end

      def find_item(list_type, filters)
        ref_dataset = DfE::ReferenceData::Degrees.const_get(list_type.to_s.upcase)

        return ref_dataset.one(filters[:id]) if filters[:id].present?

        hesa_filter = build_hesa_filter(filters)

        return ref_dataset.some(hesa_filter).first if hesa_filter.any?

        ref_dataset.all.find do |record|
          match_degree_strings(filters, record)
        end
      end

    private

      def match_degree_strings(filters, item)
        filters.compact.any? do |_, value|
          match_values(item).include?(value.downcase.strip)
        end
      end

      def match_values(item)
        [item[:name], item[:match_synonyms], item[:abbreviation]].flatten.compact.map(&:downcase).map(&:strip)
      end

      def build_hesa_filter(filters)
        {
          hesa_itt_code: remove_leading_zeros(filters[:hesa_itt_code]),
          hesa_code: remove_leading_zeros(filters[:hesa_code]),
          hecos_code: remove_leading_zeros(filters[:hecos_code]),
        }.compact
      end

      def remove_leading_zeros(code)
        code && code.to_i.to_s
      end
    end
  end
end
