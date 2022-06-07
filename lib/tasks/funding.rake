# frozen_string_literal: true

namespace :funding do
  desc "imports provider payment schedules from a provided csv"
  task :import_provider_payment_schedules, %i[csv_path first_predicted_month_index] => [:environment] do |_, args|
    attributes = Funding::Parsers::ProviderPaymentSchedules.to_attributes(file_path: args.csv_path)
    missing_ids = Funding::ProviderPaymentSchedulesImporter.call(attributes: attributes, first_predicted_month_index: args.first_predicted_month_index)
    abort("Provider accreditation ids: #{missing_ids.join(', ')} not found") unless missing_ids.empty?
  end

  desc "imports lead school payment schedules from a provided csv"
  task :import_lead_school_payment_schedules, %i[csv_path first_predicted_month_index] => [:environment] do |_, args|
    attributes = Funding::Parsers::LeadSchoolPaymentSchedules.to_attributes(file_path: args.csv_path)
    missing_urns = Funding::LeadSchoolPaymentSchedulesImporter.call(attributes: attributes, first_predicted_month_index: args.first_predicted_month_index)
    abort("Lead school URNs: #{missing_urns.join(', ')} not found") unless missing_urns.empty?
  end

  desc "imports provider trainee summaries from a provided csv"
  task :import_provider_trainee_summaries, %i[csv_path] => [:environment] do |_, args|
    attributes = Funding::Parsers::ProviderTraineeSummaries.to_attributes(file_path: args.csv_path)
    missing_ids = Funding::ProviderTraineeSummariesImporter.call(attributes: attributes)
    abort("Provider accreditation ids: #{missing_ids.join(', ')} not found") unless missing_ids.empty?
  end

  desc "imports lead school trainee summaries from a provided csv"
  task :import_lead_school_trainee_summaries, %i[csv_path] => [:environment] do |_, args|
    attributes = Funding::Parsers::LeadSchoolTraineeSummaries.to_attributes(file_path: args.csv_path)
    missing_urns = Funding::LeadSchoolTraineeSummariesImporter.call(attributes: attributes)
    abort("Lead school URNs: #{missing_urns.join(', ')} not found") unless missing_urns.empty?
  end
end
