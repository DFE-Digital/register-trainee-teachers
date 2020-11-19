# frozen_string_literal: true

class AddTraineeProgrammeDetails < ActiveRecord::Migration[6.0]
  def change
    change_table :trainees, bulk: true do |t|
      t.column :subject, :text, null: true
      t.column :age_range, :text, null: true
      t.column :programme_start_date, :date, null: true
    end
  end
end
