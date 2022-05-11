# frozen_string_literal: true

namespace :funding do
  desc "imports provider payment schedules from a provided csv"
  task :import_provider_payment_schedules, %i[csv_path first_predicted_month_index] => [:environment] do |_, args|
    attributes = Funding::Parsers::ProviderPaymentSchedules.to_attributes(file_path: args.csv_path)
    Funding::ProviderPaymentSchedulesImporter.call(attributes: attributes, first_predicted_month_index: args.first_predicted_month_index)
  end

  desc "imports lead school payment schedules from a provided csv"
  task :import_lead_school_payment_schedules, %i[csv_path first_predicted_month_index] => [:environment] do |_, args|
    attributes = Funding::Parsers::LeadSchoolPaymentSchedules.to_attributes(file_path: args.csv_path)
    Funding::LeadSchoolPaymentSchedulesImporter.call(attributes: attributes, first_predicted_month_index: args.first_predicted_month_index)
  end

  desc "imports provider trainee summaries from a provided csv"
  task :import_provider_trainee_summaries, %i[csv_path] => [:environment] do |_, args|
    attributes = Funding::Parsers::ProviderTraineeSummaries.to_attributes(file_path: args.csv_path)
    Funding::ProviderTraineeSummariesImporter.call(attributes: attributes)
  end

  desc "imports lead school trainee summaries from a provided csv"
  task :import_lead_school_trainee_summaries, %i[csv_path] => [:environment] do |_, args|
    attributes = Funding::Parsers::LeadSchoolTraineeSummaries.to_attributes(file_path: args.csv_path)
    Funding::LeadSchoolTraineeSummariesImporter.call(attributes: attributes)
  end
end
