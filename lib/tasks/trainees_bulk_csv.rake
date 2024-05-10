# frozen_string_literal: true

namespace :trainees do
  desc "Bulk import trainees from a CSV file"
  task :bulk_csv, %i[provider_code csv_path] => :environment do |_, args|
    provider = Provider.find_by!(code: args.fetch(:provider_code))

    Trainees::CreateFromBulkCsv.call(provider: provider, csv_path: args.fetch(:csv_path))
    puts("Bulk import complete")
  rescue ActiveRecord::RecordNotFound => e
    puts("Invalid provider code: #{e.message}")
  rescue KeyError => e
    puts("Missing required arguments: #{e.message}")
  end
end
