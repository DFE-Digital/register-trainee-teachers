# frozen_string_literal: true

class RemoveRedundantFieldsFromTrainees < ActiveRecord::Migration[6.0]
  def up
    change_table :trainees, bulk: true do |t|
      t.remove :ethnicity
      t.remove :disability
      t.remove :full_time_part_time
      t.remove :teaching_scholars
      t.remove :start_date
    end
  end

  def down
    change_table :trainees, bulk: true do |t|
      t.column :ethnicity, :text
      t.column :disability, :text
      t.column :full_time_part_time, :text
      t.column :teaching_scholars, :text
      t.column :start_date, :date
    end
  end
end
