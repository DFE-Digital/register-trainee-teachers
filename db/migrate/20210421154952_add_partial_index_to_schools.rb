# frozen_string_literal: true

class AddPartialIndexToSchools < ActiveRecord::Migration[6.1]
  def change
    add_index :schools, :lead_school, where: "lead_school IS TRUE"
  end
end
