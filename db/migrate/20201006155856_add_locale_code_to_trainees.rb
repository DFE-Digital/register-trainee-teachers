# frozen_string_literal: true

class AddLocaleCodeToTrainees < ActiveRecord::Migration[6.0]
  def change
    add_column :trainees, :locale_code, :integer
    add_index :trainees, :locale_code
  end
end
