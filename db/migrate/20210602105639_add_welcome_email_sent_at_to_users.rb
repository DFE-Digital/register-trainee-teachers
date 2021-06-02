# frozen_string_literal: true

class AddWelcomeEmailSentAtToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :welcome_email_sent_at, :datetime
  end
end
