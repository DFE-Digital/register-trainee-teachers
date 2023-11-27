# frozen_string_literal: true

class DropTraineesApplicationChoiceIdForeignKey < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :trainees, :apply_applications, column: :application_choice_id, primary_key: :apply_id, validate: false
  end
end
