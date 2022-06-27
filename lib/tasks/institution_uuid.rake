# frozen_string_literal: true

namespace :degrees do
  desc "add institution_uuid to degrees"
  task add_institution_uuid: :environment do
    degrees = Degree.uk

    def hesa_code_for_institute(degree)
      Hesa::CodeSets::Institutions::MAPPING.filter_map do |institute|
        if institute.include?(degree.institution)
          institute.first.to_i.to_s
        end
      end
    end

    degrees.find_each do |degree|
      hesa_code_for_institute = hesa_code_for_institute(degree)
      next if hesa_code_for_institute.blank?

      institutions = DfE::ReferenceData::Degrees::INSTITUTIONS.some({ hesa_itt_code: hesa_code_for_institute.first })
      degree.update_columns(institution_uuid: institutions&.first&.id)
    end

    degrees = degrees.where(institution_uuid: nil)

    degrees.find_each do |degree|
      institutions = DfE::ReferenceData::Degrees::INSTITUTIONS.all.filter do |record|
        ([record.name] + record.suggestion_synonyms + record.match_synonyms).include?(degree.institution)
      end

      degree.update_columns(institution_uuid: institutions&.first&.id)
    end

    puts "Done! UK degrees updated."
  end
end
