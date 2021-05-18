# frozen_string_literal: true

class ChangeTraineeAgeRangeToEnumType < ActiveRecord::Migration[6.1]
  def up
    change_column :trainees, :age_range, :integer
  end

  def down
    change_column :trainees, :age_range, :text
  end
end
