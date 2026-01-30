# frozen_string_literal: true

class CreateNewPartnerUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :new_partner_users do |t|
      t.string :description

      t.timestamps
    end
  end
end
