# frozen_string_literal: true

class AddMoreColumnsToHesaStudents < ActiveRecord::Migration[6.1]
  def change
    rename_column :hesa_students, :disability, :disability1
    change_table :hesa_students, bulk: true do |t|
      t.column :commencement_date, :string, null: true
      t.column :itt_commencement_date, :string, null: true
      t.column :disability2, :string, null: true
      t.column :disability3, :string, null: true
      t.column :disability4, :string, null: true
      t.column :disability5, :string, null: true
      t.column :disability6, :string, null: true
      t.column :disability7, :string, null: true
      t.column :disability8, :string, null: true
      t.column :disability9, :string, null: true
    end
  end
end
