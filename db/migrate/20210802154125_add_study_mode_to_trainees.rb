# frozen_string_literal: true

class AddStudyModeToTrainees < ActiveRecord::Migration[6.1]
  def change
    add_column :trainees, :study_mode, :integer
  end
end
