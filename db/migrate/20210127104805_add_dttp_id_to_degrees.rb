# frozen_string_literal: true

class AddDttpIdToDegrees < ActiveRecord::Migration[6.1]
  def change
    add_column :degrees, :dttp_id, :uuid
    add_index :degrees, :dttp_id
  end
end
