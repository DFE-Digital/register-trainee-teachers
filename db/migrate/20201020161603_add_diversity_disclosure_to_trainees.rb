# frozen_string_literal: true

class AddDiversityDisclosureToTrainees < ActiveRecord::Migration[6.0]
  def change
    add_column :trainees, :diversity_disclosure, :integer
    add_index :trainees, :diversity_disclosure
  end
end
