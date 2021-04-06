# frozen_string_literal: true

class AddRouteToCourse < ActiveRecord::Migration[6.1]
  def change
    add_column :courses, :route, :integer, null: false
  end
end
