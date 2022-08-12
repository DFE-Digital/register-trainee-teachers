# frozen_string_literal: true

class AddRecordSourceFieldToTrainees < ActiveRecord::Migration[6.1]
  def change
    add_column :trainees, :record_source, :string
  end
end
