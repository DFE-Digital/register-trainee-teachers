# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users, id: :uuid do |t|
      t.belongs_to :provider, type: :uuid, index: true, null: false, foreign_key: { to_table: :providers }
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false, index: true
      t.string :dfe_sign_in_uid, index: { unique: true }
      t.datetime :last_signed_in_at
      t.uuid :dttp_id
      t.timestamps
    end
  end
end
