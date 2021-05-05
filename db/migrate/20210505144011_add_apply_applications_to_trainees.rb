# frozen_string_literal: true

class AddApplyApplicationsToTrainees < ActiveRecord::Migration[6.1]
  def change
    add_reference :trainees, :apply_application, foreign_key: true
  end
end
