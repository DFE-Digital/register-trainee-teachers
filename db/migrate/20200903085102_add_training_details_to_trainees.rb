# rubocop:disable Rails/ThreeStateBooleanColumn
# frozen_string_literal: true

class AddTrainingDetailsToTrainees < ActiveRecord::Migration[6.0]
  def change
    change_table :trainees, bulk: true do |t|
      t.column :start_date, :date, null: true
      t.column :full_time_part_time, :text, null: true
      t.column :teaching_scholars, :boolean, null: true
    end
  end
end
# rubocop:enable Rails/ThreeStateBooleanColumn
