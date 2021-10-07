# frozen_string_literal: true

class RemoveUniqueConstraintFromCourses < ActiveRecord::Migration[6.1]
  FIELDS = %i[code accredited_body_code].freeze

  def up
    # Remove unique constraint on these two fields as we have the uuid for that
    remove_index :courses, FIELDS
    # Re add the indexes without the unique constraint
    add_index :courses, FIELDS
  end

  def down
    add_index :courses, FIELDS, unique: true
  end
end
