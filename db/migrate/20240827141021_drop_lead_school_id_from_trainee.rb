# frozen_string_literal: true

class DropLeadSchoolIdFromTrainee < ActiveRecord::Migration[7.2]
  def change
    safety_assured { remove_column :trainees, :lead_school_id, :bigint }
  end
end
