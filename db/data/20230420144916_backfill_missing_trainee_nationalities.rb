# frozen_string_literal: true

class BackfillMissingTraineeNationalities < ActiveRecord::Migration[7.0]
  def up
    Trainee.where.missing(:nationalities).joins(:hesa_students).find_each do |trainee|
      nationality = trainee.hesa_students.last.nationality

      next unless nationality

      nationality_name = ApplyApi::CodeSets::Nationalities::MAPPING[nationality]
      trainee.nationalities = Nationality.where(name: nationality_name)
      trainee.save
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
