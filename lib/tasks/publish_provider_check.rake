# frozen_string_literal: true

namespace :publish_providers do
  desc "Fetch the list of providers from the Publish service and compare with Register's providers"
  task :compare, %i[current_recruitment_cycle_year] => [:environment] do |_, args|
    checker = TeacherTrainingApi::PublishProviderChecker.call(
      recruitment_cycle_year: args.current_recruitment_cycle_year || Settings.current_recruitment_cycle_year,
    )

    puts("Publish providers that match a Register lead school")
    checker.school_matches.each do |provider|
      puts("#{provider['name']} (#{provider['code']})")
    end

    puts("")
    puts("Publish providers that match a Register training partner")
    checker.training_partner_matches.each do |provider|
      puts("#{provider['name']} (#{provider['code']})")
    end

    puts("")
    puts("Publish providers that match a Register provider")
    checker.provider_matches.each do |provider|
      puts("#{provider['name']} (#{provider['code']})")
    end

    puts("")
    puts("Publish providers not found in Register")
    checker.missing.each do |provider|
      puts("#{provider['name']} (code: #{provider['code']}, urn: #{provider['urn']}, ukprn: #{provider['ukprn']}, type: #{provider['provider_type']})")
    end

    puts("")
    puts("Matching lead schools:  #{checker.school_matches.count}")
    puts("Matching training partners: #{checker.training_partner_matches.count}")
    puts("Matching providers:     #{checker.provider_matches.count}")
    puts("Missing providers:      #{checker.missing.count}")
    puts("Total:                  #{checker.total_count}")
  end
end
