# frozen_string_literal: true

class CreateValidationErrors < ActiveRecord::Migration[6.1]
  def change
    create_table :validation_errors do |t|
      t.belongs_to :user
      t.string :form_object
      t.jsonb :details

      t.timestamps
    end
  end
end
