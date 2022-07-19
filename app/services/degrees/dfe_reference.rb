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
        DfE::ReferenceData::Degrees.const_get(list_type.to_s.upcase).all.find do |record|
          filters.compact.any? do |field, value|
            same_string?(record[field], value)
          end
        end
      end
    end
  end
end
