# frozen_string_literal: true

class BackfillProviderUkprns < ActiveRecord::Migration[6.1]
  def up
    missing_ukprn_providers = Provider.where(ukprn: nil)
    missing_ukprn_providers.each do |provider|
      dttp_provider = Dttp::Provider.find_by(dttp_id: provider.dttp_id)
      provider.update(ukprn: dttp_provider.ukprn) if dttp_provider.present?
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
