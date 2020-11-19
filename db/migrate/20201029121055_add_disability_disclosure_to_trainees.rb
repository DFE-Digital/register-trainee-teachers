# frozen_string_literal: true

class AddDisabilityDisclosureToTrainees < ActiveRecord::Migration[6.0]
  def change
    add_column :trainees, :disability_disclosure, :integer
    add_index :trainees, :disability_disclosure
  end
end
