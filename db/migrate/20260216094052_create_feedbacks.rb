# frozen_string_literal: true

class CreateFeedbacks < ActiveRecord::Migration[8.0]
  def change
    create_table :feedbacks do |t|
      t.string :satisfaction_level, null: false
      t.string :improvement_suggestion
      t.string :email

      t.timestamps
    end
  end
end
