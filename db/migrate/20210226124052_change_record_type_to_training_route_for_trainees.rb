# frozen_string_literal: true

class ChangeRecordTypeToTrainingRouteForTrainees < ActiveRecord::Migration[6.1]
  def change
    rename_column :trainees, :record_type, :training_route
  end
end
