# frozen_string_literal: true

class FixDegreesWithUnmappedTypes < ActiveRecord::Migration[6.1]
  def up
    unmappable_hesa_codes = Degrees::CreateFromHesa::HONOURS_TO_NON_HONOURS_HESA_CODE_MAP.keys

    Trainee.imported_from_hesa.find_each do |trainee|
      if trainee.hesa_student&.degrees&.any? { |degree| unmappable_hesa_codes.include?(degree["degree_type"]) }
        Degree.without_auditing do
          trainee.degrees.uk.where(uk_degree: nil).delete_all
          hesa_degrees = trainee.hesa_student.degrees.map(&:with_indifferent_access)
          Degrees::CreateFromHesa.call(trainee: trainee, hesa_degrees: hesa_degrees)
        end
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
