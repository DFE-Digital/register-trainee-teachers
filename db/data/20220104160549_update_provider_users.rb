# frozen_string_literal: true

class UpdateProviderUsers < ActiveRecord::Migration[6.1]
  def up
    User.where.not(provider_id: nil).find_each do |user|
      ProviderUser.find_or_create_by!(
        provider_id: user.provider_id,
        user_id: user.id,
      )
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
