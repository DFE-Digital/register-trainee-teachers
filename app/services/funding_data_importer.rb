# frozen_string_literal: true

class FundingDataImporter
  def initialize(funding_upload)
    @funding_upload = funding_upload
  end

  def import_data
    @funding_upload.pending!
    case @funding_upload.funding_type
    when "provider_payment_schedule"
      import_provider_payment_schedules
    when "lead_partner_payment_schedule"
      import_lead_partner_payment_schedules
    when "provider_trainee_summary"
      import_provider_trainee_summaries
    when "lead_partner_trainee_summary"
      import_lead_partner_trainee_summaries
    else
      return false
    end
    @funding_upload.processed!
  rescue StandardError
    @funding_upload.failed!
  end

private

  def import_provider_payment_schedules
    attributes = Funding::Parsers::ProviderPaymentSchedules.to_attributes(funding_upload: @funding_upload)
    missing_ids = Funding::ProviderPaymentSchedulesImporter.call(attributes: attributes, first_predicted_month_index: @funding_upload.month)
    raise("Provider accreditation ids: #{missing_ids.join(', ')} not found") if missing_ids.present?
  end

  def import_lead_partner_payment_schedules
    attributes = Funding::Parsers::TrainingPartnerPaymentSchedules.to_attributes(funding_upload: @funding_upload)
    missing_urns = Funding::TrainingPartnerPaymentSchedulesImporter.call(attributes: attributes, first_predicted_month_index: @funding_upload.month)
    raise("Lead partner URNs: #{missing_urns.join(', ')} not found") if missing_urns.present?
  end

  def import_provider_trainee_summaries
    attributes = Funding::Parsers::ProviderTraineeSummaries.to_attributes(funding_upload: @funding_upload)
    missing_ids = Funding::ProviderTraineeSummariesImporter.call(attributes:)
    raise("Provider accreditation ids: #{missing_ids.join(', ')} not found") if missing_ids.present?
  end

  def import_lead_partner_trainee_summaries
    attributes = Funding::Parsers::LeadPartnerTraineeSummaries.to_attributes(funding_upload: @funding_upload)
    missing_urns = Funding::LeadPartnerTraineeSummariesImporter.call(attributes:)
    raise("Lead partner URNs: #{missing_urns.join(', ')} not found") if missing_urns.present?
  end
end
