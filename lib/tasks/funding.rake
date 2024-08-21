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
    attributes = Funding::Parsers::LeadPartnerPaymentSchedules.to_attributes(file_path: args.csv_path)
    missing_urns = Funding::LeadPartnerPaymentSchedulesImporter.call(attributes: attributes, first_predicted_month_index: args.first_predicted_month_index)
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
    attributes = Funding::Parsers::LeadPartnerTraineeSummaries.to_attributes(file_path: args.csv_path)
    missing_urns = Funding::LeadPartnerTraineeSummariesImporter.call(attributes:)
    abort("Lead school URNs: #{missing_urns.join(', ')} not found") unless missing_urns.empty?
  end

  desc "Set the route_type to the corresponding translation key defaults to academic_year 2024/2025 unless specified: rails funding:generate_trainee_summary_row_route_type or 'funding:generate_trainee_summary_row_route_type[2024/2025]'"
  task :generate_trainee_summary_row_route_type, %i[academic_year] => :environment do |_, args|
    Funding::UpdateTraineeSummaryRowRouteService.call(args[:academic_year])
  end
end
