# frozen_string_literal: true

module Degrees
  class DfeReference
    class << self
      include MappingsHelper

      def find_subject(uuid: nil, name: nil, hecos_code: nil)
        find_item(:single_subjects, id: uuid, hecos_code: sanitised_hesa(hecos_code), name: name)
      end

      def find_type(uuid: nil, abbreviation: nil, hesa_code: nil)
        find_item(:types_including_generics,
                  id: uuid,
                  hesa_itt_code: sanitised_hesa(hesa_code),
                  abbreviation: abbreviation)
      end

      def find_institution(uuid: nil, name: nil, hesa_code: nil)
        find_item(:institutions, id: uuid, hesa_itt_code: sanitised_hesa(hesa_code), name: name)
      end

      def find_grade(uuid: nil, name: nil, hesa_code: nil)
        find_item(:grades, id: uuid, hesa_code: sanitised_hesa(hesa_code), name: name)
      end

      def find_item(list_type, filters)
        ref_dataset = DfE::ReferenceData::Degrees.const_get(list_type.to_s.upcase)

        hesa_filter = {
          hesa_itt_code: filters[:hesa_itt_code],
          hesa_code: filters[:hesa_code],
          hecos_code: filters[:hecos_code],
        }.compact

        return ref_dataset.one(filters[:id]) if filters[:id].present?

        return ref_dataset.some(hesa_filter).first if hesa_filter.any?

        ref_dataset.all.find do |record|
          match_degree_strings(filters, record)
        end
      end

    private

      def match_values(item)
        [item[:name], item[:match_synonyms], item[:abbreviation]].flatten.compact.map(&:downcase).map(&:strip)
      end

      def match_degree_strings(filters, item)
        filters.compact.any? do |_field, value|
          match_values(item).include?(value.downcase.strip)
        end
      end
    end
  end
end
