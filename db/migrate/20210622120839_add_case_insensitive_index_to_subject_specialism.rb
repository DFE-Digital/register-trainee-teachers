# frozen_string_literal: true

class AddCaseInsensitiveIndexToSubjectSpecialism < ActiveRecord::Migration[6.1]
  def change
    remove_index :subject_specialisms, :name
    add_index :subject_specialisms, "lower(name)", unique: true
  end
end
