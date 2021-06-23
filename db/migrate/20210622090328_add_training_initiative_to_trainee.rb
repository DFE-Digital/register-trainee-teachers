# frozen_string_literal: true

class AddTrainingInitiativeToTrainee < ActiveRecord::Migration[6.1]
  def change
    add_column :trainees, :training_initiative, :integer
  end
end
