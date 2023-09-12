# frozen_string_literal: true

class BackfillProviderAccreditationId < ActiveRecord::Migration[6.1]
  def up
    Provider.where(accreditation_id: nil).find_each do |provider|
      dttp_account = Dttp::Account.find_by(dttp_id: provider.dttp_id)
      provider.update(accreditation_id: dttp_account.accreditation_id) if dttp_account.present?
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
