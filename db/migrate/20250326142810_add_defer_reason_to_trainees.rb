# frozen_string_literal: true

class AddDeferReasonToTrainees < ActiveRecord::Migration[7.2]
  def change
    add_column :trainees, :defer_reason, :string
  end
end
