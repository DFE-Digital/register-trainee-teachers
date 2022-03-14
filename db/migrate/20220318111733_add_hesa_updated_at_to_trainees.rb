# frozen_string_literal: true

class AddHesaUpdatedAtToTrainees < ActiveRecord::Migration[6.1]
  def change
    add_column :trainees, :hesa_updated_at, :datetime
  end
end
