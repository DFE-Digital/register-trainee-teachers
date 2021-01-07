# frozen_string_literal: true

class ChangeTraineeAgeRangeToEnumType < ActiveRecord::Migration[6.1]
  def up
    sql = Trainee.age_ranges.reduce(String.new) { |s, (k, v)| s << "WHEN '#{k}' THEN #{v}::integer " }
    change_column :trainees, :age_range, "integer USING (CASE age_range #{sql} END)"
  end

  def down
    sql = Trainee.age_ranges.reduce(String.new) { |s, (k, v)| s << "WHEN #{v} THEN '#{k}'::text " }
    change_column :trainees, :age_range, "text USING (CASE age_range #{sql} END)"
  end
end
