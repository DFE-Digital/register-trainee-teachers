# frozen_string_literal: true

class AddPublishedToAcademicCycles < ActiveRecord::Migration[8.1]
  def change
    add_column :academic_cycles, :published, :boolean, default: false, null: false
  end
end
