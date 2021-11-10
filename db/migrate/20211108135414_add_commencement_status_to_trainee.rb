# frozen_string_literal: true

class AddCommencementStatusToTrainee < ActiveRecord::Migration[6.1]
  def change
    add_column :trainees, :commencement_status, :integer
  end
end
