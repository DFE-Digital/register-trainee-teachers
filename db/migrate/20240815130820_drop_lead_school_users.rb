# frozen_string_literal: true

class DropLeadSchoolUsers < ActiveRecord::Migration[7.1]
  def change
    drop_table :lead_school_users do |t|
      t.references :lead_school, null: false, foreign_key: { to_table: :schools }
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
