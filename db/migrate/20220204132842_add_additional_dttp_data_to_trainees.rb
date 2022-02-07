# frozen_string_literal: true

class AddAdditionalDttpDataToTrainees < ActiveRecord::Migration[6.1]
  def change
    change_table :trainees, bulk: true do |t|
      t.jsonb :additional_dttp_data
    end
  end
end
