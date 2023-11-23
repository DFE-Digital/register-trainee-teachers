# frozen_string_literal: true

class AddTraineesApplicationChoiceId < ActiveRecord::Migration[7.0]
  def change
    add_column :trainees, :application_choice_id, :integer, null: true
    add_foreign_key :trainees, :apply_applications, column: :application_choice_id, primary_key: :apply_id, validate: false
  end
end
