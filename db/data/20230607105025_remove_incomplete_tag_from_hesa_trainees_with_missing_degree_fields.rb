# frozen_string_literal: true

class RemoveIncompleteTagFromHesaTraineesWithMissingDegreeFields < ActiveRecord::Migration[7.0]
  def up
    Trainee.incomplete.imported_from_hesa.find_each do |trainee|
      trainee.send(:set_submission_ready)
      trainee.save
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
