# frozen_string_literal: true

class AddSummaryToCourses < ActiveRecord::Migration[6.1]
  def change
    add_column :courses, :summary, :string, null: false
  end
end
