# frozen_string_literal: true

module Dttp
  class ImportProvider
    include ServicePattern

    def initialize(provider_hash:)
      @provider_hash = provider_hash
    end

    def call
      provider.update!(attributes)
    end

  private

    attr_reader :provider_hash

    def attributes
      {
        name: provider_hash["name"],
        ukprn: provider_hash["dfe_ukprn"],
        dttp_id: account_id,
      }
    end

    def provider
      @provider ||= Dttp::Provider.find_or_initialize_by(dttp_id: account_id)
    end

    def account_id
      @account_id ||= provider_hash["accountid"]
    end
  end
end
