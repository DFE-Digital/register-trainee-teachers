# frozen_string_literal: true

class AddIqtsCountryToTrainees < ActiveRecord::Migration[6.1]
  def change
    add_column :trainees, :iqts_country, :string
  end
end
