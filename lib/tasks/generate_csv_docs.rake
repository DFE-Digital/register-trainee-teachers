# frozen_string_literal: true

require "csv"

desc "Disposable task to generate YAML file from CSV formatted bulk trainee upload reference docs."
task generate_csv_docs: :environment do
  table = CSV.table(Rails.root.join("tmp/trainee_bulk_upload_reference.csv"))
  data = table.map(&:to_hash)
  File.open("tmp/trainee_bulk_upload_reference.yaml", "w") do |f|
    f.puts(data.to_yaml)
  end
end
