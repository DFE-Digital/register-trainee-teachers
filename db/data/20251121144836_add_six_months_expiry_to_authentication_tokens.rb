# frozen_string_literal: true

class AddSixMonthsExpiryToAuthenticationTokens < ActiveRecord::Migration[7.2]
  def up
    AuthenticationToken.where(expires_at: nil).update_all(expires_at: 6.months.from_now)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
