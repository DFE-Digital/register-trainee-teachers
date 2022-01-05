# frozen_string_literal: true

class CreateLeadSchoolUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :lead_school_users do |t|
      t.references :lead_school, foreign_key: { to_table: :schools }, index: true, null: false
      t.references :user, foreign_key: { to_table: :users }, index: true, null: false
      t.timestamps
    end
  end
end
