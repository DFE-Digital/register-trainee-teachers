# frozen_string_literal: true

class DropTraineeAddressColumns < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      remove_column :trainees, :address_line_one, :text
      remove_column :trainees, :address_line_two, :text
      remove_column :trainees, :town_city, :text
      remove_column :trainees, :postcode, :text
      remove_column :trainees, :locale_code, :integer
      remove_column :trainees, :international_address, :text
    end
  end
end
