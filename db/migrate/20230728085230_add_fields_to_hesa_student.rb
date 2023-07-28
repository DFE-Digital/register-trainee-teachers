# frozen_string_literal: true

class AddFieldsToHesaStudent < ActiveRecord::Migration[7.0]
  def change
    add_column :hesa_students, :application_choice_id, :string
    add_column :hesa_students, :itt_start_date, :string
    add_column :hesa_students, :trainee_start_date, :string
  end
end
