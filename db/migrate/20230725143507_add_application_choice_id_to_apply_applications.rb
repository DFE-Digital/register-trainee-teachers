# frozen_string_literal: true

class AddApplicationChoiceIdToApplyApplications < ActiveRecord::Migration[7.0]
  def change
    add_column :apply_applications, :application_choice_id, :string
  end
end
