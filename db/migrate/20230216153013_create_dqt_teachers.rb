# frozen_string_literal: true

class CreateDqtTeachers < ActiveRecord::Migration[7.0]
  def change
    create_table :dqt_teachers do |t|
      t.column :trn, :string
      t.column :first_name, :string
      t.column :last_name, :string
      t.column :date_of_birth, :string
      t.column :qts_date, :string
      t.column :eyts_date, :string
      t.column :early_years_status_name, :string
      t.column :early_years_status_value, :string
      t.timestamps
    end
  end
end
