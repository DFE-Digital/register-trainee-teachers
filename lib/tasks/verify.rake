# frozen_string_literal: true

namespace :verify do
  desc "Verify record sources"
  task record_sources: :environment do
    total = Trainee.count
    mismatches = {}
    mapping_rules = {
      Sourceable::DTTP_SOURCE => ->(t) { t.created_from_dttp? },
      Sourceable::HESA_COLLECTION_SOURCE => ->(t) { t.hesa_id.present? },
      Sourceable::HESA_TRN_DATA_SOURCE => ->(t) { t.hesa_id.present? },
      Sourceable::APPLY_SOURCE => ->(t) { t.apply_application_id.present? },
      Sourceable::MANUAL_SOURCE => ->(t) { t.apply_application_id.nil? && !t.created_from_dttp? && !t.hesa_id? },
    }

    Trainee.find_each.with_index do |trainee, index|
      source = trainee.record_source
      mismatches[source] += 1 unless mapping_rules[source]&.call(trainee)

      progress = ((index + 1).to_f / total * 100).round(2)
      puts "Progress: #{progress}%"
    end

    puts "Mismatch counts:"
    mismatches.each do |source, count|
      puts "#{source}: #{count}"
    end
  end
end
