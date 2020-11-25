# frozen_string_literal: true

class AddDfESignInDetailsToUser < ActiveRecord::Migration[6.0]
  def change
    change_table :users, bulk: true do |t|
      t.string :dfe_sign_in_uid, null: true
      t.datetime :last_signed_in_at, null: true
    end

    add_index :users, :dfe_sign_in_uid, unique: true
  end
end
