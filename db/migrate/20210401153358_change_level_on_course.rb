# frozen_string_literal: true

class ChangeLevelOnCourse < ActiveRecord::Migration[6.1]
  def up
    remove_column :courses, :level

    change_table :courses, bulk: true do |t|
      t.column :level, :integer, null: false
    end
  end

  def down
    remove_column :courses, :level

    change_table :courses, bulk: true do |t|
      t.column :level, :string, null: false
    end
  end
end
