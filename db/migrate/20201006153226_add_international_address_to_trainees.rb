# frozen_string_literal: true

class AddInternationalAddressToTrainees < ActiveRecord::Migration[6.0]
  def change
    add_column :trainees, :international_address, :text, null: true
  end
end
