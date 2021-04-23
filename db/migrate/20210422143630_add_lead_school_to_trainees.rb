# frozen_string_literal: true

class AddLeadSchoolToTrainees < ActiveRecord::Migration[6.1]
  def change
    add_reference :trainees, :lead_school, foreign_key: { to_table: "schools" }
  end
end
