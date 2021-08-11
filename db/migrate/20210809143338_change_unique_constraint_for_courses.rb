# frozen_string_literal: true

class ChangeUniqueConstraintForCourses < ActiveRecord::Migration[6.1]
  def change
    remove_index :courses, :code, unique: true
    add_index :courses, %i[code accredited_body_code], unique: true
  end
end
