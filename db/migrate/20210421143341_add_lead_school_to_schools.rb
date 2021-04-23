# frozen_string_literal: true

class AddLeadSchoolToSchools < ActiveRecord::Migration[6.1]
  def change
    add_column :schools, :lead_school, :boolean, null: false
  end
end
