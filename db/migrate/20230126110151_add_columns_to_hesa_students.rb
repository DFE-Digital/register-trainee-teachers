# frozen_string_literal: true

class AddColumnsToHesaStudents < ActiveRecord::Migration[7.0]
  def change
    change_table :hesa_students, bulk: true do |t|
      t.column :itt_key, :string, null: true
      t.column :rec_id, :string, null: true
      t.column :status, :string, null: true
      t.column :allocated_place, :string, null: true
      t.column :provider_course_id, :string, null: true
      t.column :initiatives_two, :string, null: true
      t.column :ni_number, :string, null: true
      t.column :numhus, :string, null: true
      t.column :previous_surname, :string, null: true
      t.column :surname16, :string, null: true
      t.column :ttcid, :string, null: true
      t.column :hesa_committed_at, :string, null: true
      t.index %i[hesa_id rec_id], unique: true
    end
  end
end
