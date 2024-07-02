# frozen_string_literal: true

namespace :copy_lead_schools_to_lead_partners do
  desc "Copy lead school records to lead partners"
  task copy: :environment do |_, args|
    CopyProvidersToLeadPartnersService.call(provider_ids: args.extras)
    puts "Providers with ids #{args.extras.join(', ')} and ProviderUser records copied to lead partners successfully."
  end
end
