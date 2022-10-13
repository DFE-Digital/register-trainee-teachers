# frozen_string_literal: true

class AddUniqueIndexToTraineeDisabilities < ActiveRecord::Migration[6.1]
  def change
    add_index :trainee_disabilities, %i[disability_id trainee_id], unique: true
  end
end
