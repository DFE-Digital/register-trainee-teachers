# frozen_string_literal: true

namespace :vendor do
  desc "Create vendor providers by commandeering existing large SCITT providers"
  task create: :environment do
    raise "THIS TASK CANNOT BE RUN IN PRODUCTION" if Rails.env.production?

    vendor_names = %w[Tribal
                      Ellucian
                      ThesisCloud
                      Oracle
                      PwC
                      Unit-e
                      Technology1]
    # Get active SCITT Providers with the most trainees so HEIs aren't affected
    provider_ids = Trainee.group(:provider_id)
      .where(provider_id: Provider.active_scitt)
      .order(count_all: :desc)
      .count
      .take(vendor_names.count)
      .shuffle
      .map { |provider_id, _count_all| provider_id }

    vendor_names.each_with_index do |vendor_name, index|
      task = Rake::Task["vendor:transform"]

      task.invoke(vendor_name, provider_ids[index])
      task.reenable
    end
  end

  desc "Transform an existing provider to a vendor provider"
  task :transform, :vendor_name, :provider_id_to_replace do |_, args|
    raise "THIS TASK CANNOT BE RUN IN PRODUCTION" if Rails.env.production?

    Faker::Config.locale = "en-GB"

    vendor_name, provider_id_to_replace = *args

    existing_provider = Provider.find(provider_id_to_replace)
    puts "Transforming: #{existing_provider.name_and_code} to #{vendor_name}"

    existing_provider.update(
      dttp_id: SecureRandom.uuid,
      accreditation_id: Faker::Number.between(from: 1600, to: 1999),
      ukprn: Faker::Number.number(digits: 8),
      code: Faker::Alphanumeric.alphanumeric(number: 3).upcase,
      name: vendor_name,
    )

    token = AuthenticationToken.create_with_random_token(provider: existing_provider, created_by: existing_provider.users.first, name: "Sandbox Token").token
    puts "Token: `#{token}`"
  end
end
