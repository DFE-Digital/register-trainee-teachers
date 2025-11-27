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
    attributes = Funding::Parsers::TrainingPartnerPaymentSchedules.to_attributes(file_path: args.csv_path)
    missing_urns = Funding::TrainingPartnerPaymentSchedulesImporter.call(attributes: attributes, first_predicted_month_index: args.first_predicted_month_index)
    abort("Lead school URNs: #{missing_urns.join(', ')} not found") unless missing_urns.empty?
  end

  desc "imports provider trainee summaries from a provided csv"
  task :import_provider_trainee_summaries, %i[csv_path] => [:environment] do |_, args|
    attributes = Funding::Parsers::ProviderTraineeSummaries.to_attributes(file_path: args.csv_path)
    missing_ids = Funding::ProviderTraineeSummariesImporter.call(attributes:)
    abort("Provider accreditation ids: #{missing_ids.join(', ')} not found") unless missing_ids.empty?
  end

  desc "imports lead school trainee summaries from a provided csv"
  task :import_lead_school_trainee_summaries, %i[csv_path] => [:environment] do |_, args|
    attributes = Funding::Parsers::TrainingPartnerTraineeSummaries.to_attributes(file_path: args.csv_path)
    missing_urns = Funding::TrainingPartnerTraineeSummariesImporter.call(attributes:)
    abort("Lead school URNs: #{missing_urns.join(', ')} not found") unless missing_urns.empty?
  end

  desc "Set the training_route to the corresponding translation key. The update will only be applied to records of the current academic year unless specified and where the training_route is nil: rails funding:generate_trainee_summary_row_training_route or 'funding:generate_trainee_summary_row_training_route[2024/25]'"
  task :generate_trainee_summary_row_training_route, %i[academic_year] => :environment do |_, args|
    Funding::UpdateTraineeSummaryRowRouteService.call(args[:academic_year])
  end
end
