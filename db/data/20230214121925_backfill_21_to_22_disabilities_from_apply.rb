# frozen_string_literal: true

class Backfill21To22DisabilitiesFromApply < ActiveRecord::Migration[7.0]
  def up
    return unless Rails.env.production?

    Upload.find(6).file.open do |blob|
      CSV.parse(blob.read.force_encoding("ISO-8859-1"), headers: true, header_converters: :symbol) do |row|
        trainee = Trainee.find_by(id: row[:trainee_id])

        next unless trainee

        if row[:action].include?("becomes disabled")
          hesa_codes = row[:hesa_codes].gsub('"', "").split(",").map(&:strip)

          trainee.disabilities = hesa_codes.map do |hesa_code|
            Disability.find_by(name: Hesa::CodeSets::Disabilities::MAPPING[hesa_code])
          end

          trainee.disability_disclosure = Diversities::DISABILITY_DISCLOSURE_ENUMS[:disabled]
          trainee.diversity_disclosure = Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed]
          trainee.save

          trainee.trainee_disabilities.each_with_index do |trainee_disability, index|
            if trainee_disability.disability.name == Diversities::OTHER
              trainee_disability.update(additional_disability: JSON(row[:disabilities])[index]&.strip)
            end
          end
        else
          trainee.diversity_disclosure = Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed]
          trainee.disability_disclosure = Diversities::DISABILITY_DISCLOSURE_ENUMS[:no_disability]
          trainee.disabilities = []
          trainee.save
        end
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
