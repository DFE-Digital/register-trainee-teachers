# frozen_string_literal: true

class AddDisabilityInformationToTraineeDisabilities < ActiveRecord::Migration[6.0]
  def change
    add_column :trainee_disabilities, :additional_disability, :text, null: true
  end
end
