class AddSixMonthsExpiryToAuthenticationTokens < ActiveRecord::Migration[7.2]
  def up
    AuthenticationToken.where(expires_at: nil).update_all(expires_at: Time.current + 6.months)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
