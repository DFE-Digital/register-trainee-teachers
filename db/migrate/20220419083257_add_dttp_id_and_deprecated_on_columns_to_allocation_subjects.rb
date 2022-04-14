# frozen_string_literal: true

class AddDttpIdAndDeprecatedOnColumnsToAllocationSubjects < ActiveRecord::Migration[6.1]
  def change
    change_table :allocation_subjects, bulk: true do |t|
      t.string :dttp_id, index: { unique: true }
      t.date :deprecated_on
    end
  end
end
