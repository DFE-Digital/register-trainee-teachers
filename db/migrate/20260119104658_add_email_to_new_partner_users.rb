# frozen_string_literal: true
#
class AddEmailToNewPartnerUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :new_partner_users, :email, :string
  end
end
