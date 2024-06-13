class DropApplicationChoiceIdFromApplyApplications < ActiveRecord::Migration[7.1]
  def change
    safety_assured { remove_column :apply_applications, :application_choice_id }
  end
end
