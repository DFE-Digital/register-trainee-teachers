# frozen_string_literal: true

class AddStatusToDttpTrainees < ActiveRecord::Migration[6.1]
  def change
    add_column :dttp_trainees, :status, :uuid
  end
end
