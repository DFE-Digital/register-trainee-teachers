# frozen_string_literal: true

class CreateUploads < ActiveRecord::Migration[6.1]
  def change
    create_table :uploads do |t|
      t.timestamps

      t.string :name, null: false
      t.belongs_to :user, null: false, foreign_key: true
    end
  end
end
