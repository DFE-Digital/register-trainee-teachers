# frozen_string_literal: true

module Degrees
  class DfEReference
    OTHER = "Other"

    COMMON_TYPES = ["Bachelor of Arts", "Bachelor of Science", "Master of Arts", "PhD"].freeze

    GRADES = DfE::ReferenceData::Degrees::GRADES
    SUBJECTS = DfE::ReferenceData::Degrees::SUBJECTS_INCLUDING_GENERICS

    ## TODO: Remove this once the dfe-reference-data gem is updated to the latest version

    # Extracts the mapping from https://github.com/DFE-Digital/dfe-reference-data/blob/03cb8815684355b1e04f2b0e39faf682d1ba7f7c/lib/dfe/reference_data/degrees/types.rb#L904
    # This is a temporary solution until we are able to upgrade the gem to its latest version

    UNKNOWN_TYPES_SCHEMA = DfE::ReferenceData::Degrees::TYPES_SCHEMA.merge(
      {
        qualification: { kind: :optional, schema: :string },
        unknown: :boolean,
      },
    )

    UNKNOWN_TYPES = DfE::ReferenceData::HardcodedReferenceList.new(
      {
        "3e042de2-a453-47dc-9452-90a23399e9ee" =>
        { name: "Not available",
          abbreviation: nil,
          suggestion_synonyms: [],
          match_synonyms: [],
          hesa_itt_code: "999",
          unknown: true },
      },
      schema: UNKNOWN_TYPES_SCHEMA,
      list_description: 'Generic "catch-all" degree types, for approximating degree types not listed in TYPES (eg, "First Degree" to cover any first degree).',
      list_docs_url: "https://github.com/DFE-Digital/dfe-reference-data/blob/main/docs/lists_degrees.md#dfereferencedatadegreesgeneric_types",
      field_descriptions: DfE::ReferenceData::Degrees::TYPES_FIELD_DESCRIPTIONS,
    )

    ##########################################################################

    TYPES = DfE::ReferenceData::JoinedReferenceList.new(
      [DfE::ReferenceData::Degrees::TYPES_INCLUDING_GENERICS, UNKNOWN_TYPES],
      schema: DfE::ReferenceData::Degrees::TYPES_SCHEMA.merge(
        {
          qualification: { kind: :optional, schema: :string },
          generic: { kind: :optional, schema: :boolean },
          unknown: { kind: :optional, schema: :boolean },
        },
      ),
      list_description: "All degree types",
      field_descriptions: DfE::ReferenceData::Degrees::TYPES_FIELD_DESCRIPTIONS,
    )

    INSTITUTIONS = DfE::ReferenceData::Degrees::INSTITUTIONS_INCLUDING_GENERICS

    SUPPORTED_GRADES_BY_HESA_CODES = %w[01 02 03 05 12 13 14].freeze

    SUPPORTED_GRADES = GRADES.all_as_hash.select { |_, item|
      SUPPORTED_GRADES_BY_HESA_CODES.include?(item[:hesa_code])
    }

    SUPPORTED_GRADES_WITH_OTHER = DfE::ReferenceData::HardcodedReferenceList.new(
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

    class << self
      def find_subject(uuid: nil, name: nil, hecos_code: nil)
        find_item(:subjects, id: uuid, hecos_code: hecos_code, name: name)
      end

      def find_type(uuid: nil, name: nil, abbreviation: nil, hesa_code: nil)
        find_item(:types,
                  id: uuid,
                  name: name,
                  hesa_itt_code: hesa_code,
                  abbreviation: abbreviation)
      end

      def find_institution(uuid: nil, name: nil, hesa_code: nil, ukprn: nil)
        find_item(:institutions, id: uuid, hesa_itt_code: hesa_code, name: name, ukprn: ukprn)
      end

      def find_grade(uuid: nil, name: nil, hesa_code: nil)
        find_item(:grades, id: uuid, hesa_code: hesa_code, name: name)
      end

      def find_item(list_type, filters)
        ref_dataset = Degrees::DfEReference.const_get(list_type.to_s.upcase)

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
        [
          item[:name],
          item[:match_synonyms],
          item[:abbreviation],
          item[:ukprn],
        ].flatten.compact.map(&:downcase).map(&:strip)
      end

      def build_hesa_filter(filters)
        {
          hesa_itt_code: filters[:hesa_itt_code],
          hesa_code: filters[:hesa_code],
          hecos_code: filters[:hecos_code],
        }.compact
      end
    end
  end
end
