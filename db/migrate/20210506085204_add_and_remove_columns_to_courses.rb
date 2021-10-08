# frozen_string_literal: true

class AddAndRemoveColumnsToCourses < ActiveRecord::Migration[6.1]
  def change
    # Rubocop didn't support the "type" option at time of writing, hence the need to disable it
    change_table :courses, bulk: true do |t|
      t.remove :provider_id, type: :bigint
      t.remove :age_range, type: :integer

      t.column :accredited_body_code, :string, null: false
      t.column :min_age, :integer, null: false
      t.column :max_age, :integer, null: false

      t.change_null :course_length, true

      t.index :code, unique: true
    end
  end
end
