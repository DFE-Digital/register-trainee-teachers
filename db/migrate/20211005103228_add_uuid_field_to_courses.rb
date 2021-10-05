# frozen_string_literal: true

class AddUuidFieldToCourses < ActiveRecord::Migration[6.1]
  def change
    add_column :courses, :uuid, :uuid
    add_index :courses, :uuid, unique: true
  end
end
