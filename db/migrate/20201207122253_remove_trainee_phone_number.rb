# frozen_string_literal: true

class RemoveTraineePhoneNumber < ActiveRecord::Migration[6.0]
  def up
    remove_column :trainees, :phone_number
  end

  def down
    add_column :trainees, :phone_number, :text
  end
end
