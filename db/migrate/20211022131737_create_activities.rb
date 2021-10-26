# frozen_string_literal: true

class CreateActivities < ActiveRecord::Migration[6.1]
  def change
    create_table :activities do |t|
      t.references :user, index: true, null: false, foreign_key: { to_table: :users }

      t.string :controller_name
      t.string :action_name
      t.jsonb :metadata

      t.timestamps
    end
  end
end
