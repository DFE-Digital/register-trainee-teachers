# frozen_string_literal: true

namespace :copy_providers_to_lead_partners do
  desc "Copy provider records to lead partners"
  task :copy, %i[provider_ids record_type] => :environment do |_, args|
    provider_ids = args[:provider_ids].split
    record_type  = args[:record_type]

    CopyProvidersToLeadPartnersService.call(provider_ids:, record_type:)

    puts "Providers with ids #{provider_ids.join(', ')} and ProviderUser records copied to lead partners successfully."
  end
end
