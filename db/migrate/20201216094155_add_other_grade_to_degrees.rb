# frozen_string_literal: true

class AddOtherGradeToDegrees < ActiveRecord::Migration[6.0]
  def change
    add_column :degrees, :other_grade, :text, null: true
  end
end
