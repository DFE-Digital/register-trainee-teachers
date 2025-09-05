# frozen_string_literal: true

namespace :vendor do
  desc "Create a vendor via swap"
  task create: :environment do
    raise "THIS TASK CANNOT BE RUN IN PRODUCTION" if Rails.env.production?

    vendor_names = %w[Tribal
                      Ellucian
                      ThesisCloud
                      Oracle
                      PWC
                      Unit-e
                      TechnologyOne] + [*1..10].map { |a| "Test vendor #{a}" }
    provider_ids = Trainee.group(:provider_id).order(count_all: :desc).count.take(vendor_names.count).shuffle
      .map { |provider_id, _count_all| provider_id }

    vendor_names.each_with_index do |vendor_name, index|
      task = Rake::Task["vendor:swap"]

      task.invoke(vendor_name, provider_ids[index])
      task.reenable
    end
  end

  desc "Swap the provider to a vendor"
  task :swap, :vendor_name, :provider_id_to_replace do |_, args|
    raise "THIS TASK CANNOT BE RUN IN PRODUCTION" if Rails.env.production?

    Faker::Config.locale = "en-GB"

    vendor_name, provider_id_to_replace = *args

    existing_provider = Provider.find(provider_id_to_replace)
    puts "Swapped: #{existing_provider.name_and_code} with #{vendor_name}"

    existing_provider.update(
      dttp_id: SecureRandom.uuid,
      accreditation_id: Faker::Number.number(digits: 4),
      ukprn: Faker::Number.number(digits: 8),
      code: Faker::Alphanumeric.alphanumeric(number: 3).upcase,
      name: vendor_name,
    )

    AuthenticationToken.where(provider: existing_provider).find_each(&:delete)

    token = AuthenticationToken.create_with_random_token(provider: existing_provider, created_by: existing_provider.users.first, name: "Token").token

    puts "Token: `#{token}`"
  end
end
