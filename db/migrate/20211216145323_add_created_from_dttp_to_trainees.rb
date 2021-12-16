# frozen_string_literal: true

class AddCreatedFromDttpToTrainees < ActiveRecord::Migration[6.1]
  def change
    add_column :trainees, :created_from_dttp, :boolean, default: false, null: false
  end
end
