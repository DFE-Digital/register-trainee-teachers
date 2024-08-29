# frozen_string_literal: true

class DropLeadSchoolFromSchools < ActiveRecord::Migration[7.2]
  def change
    safety_assured { remove_column :schools, :lead_school, :boolean }
  end
end
