# frozen_string_literal: true

class AddMagicLinkTokensToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :magic_link_token, :string, unique: true
    add_column :users, :magic_link_token_sent_at, :datetime
  end
end
