class FundingDataImporter
  def initialize(funding_upload)
    @funding_upload = funding_upload
  end

  def import_data
    @funding_upload.pending!
    case @funding_upload.funding_type
    when :provider_payment_schedule
      import_provider_payment_schedules
    when :lead_school_payment_schedule
      import_lead_school_payment_schedules
    when :provider_trainee_summary
      import_provider_trainee_summaries
    when :lead_school_trainee_summary
      import_lead_school_trainee_summaries
    else
      return false
    end
    @funding_upload.processed!
  rescue
    @funding_upload.failed!
  end

  private

  def import_provider_payment_schedules
    attributes = Funding::Parsers::ProviderPaymentSchedules.to_attributes(@funding_upload)
    missing_ids = Funding::ProviderPaymentSchedulesImporter.call(attributes: attributes, first_predicted_month_index: @funding_upload.month)
    raise("Provider accreditation ids: #{missing_ids.join(', ')} not found") unless missing_ids.blank?
  end

  def import_lead_school_payment_schedules
    attributes = Funding::Parsers::LeadSchoolPaymentSchedules.to_attributes(@funding_upload)
    missing_urns = Funding::LeadSchoolPaymentSchedulesImporter.call(attributes: attributes, first_predicted_month_index: @funding_upload.month)
    raise("Lead school URNs: #{missing_urns.join(', ')} not found") unless missing_urns.blank?
  end

  def import_provider_trainee_summaries
    attributes = Funding::Parsers::ProviderTraineeSummaries.to_attributes(@funding_upload)
    missing_ids = Funding::ProviderTraineeSummariesImporter.call(attributes: attributes)
    raise("Provider accreditation ids: #{missing_ids.join(', ')} not found") unless missing_ids.blank?
  end

  def import_lead_school_trainee_summaries
    attributes = Funding::Parsers::LeadSchoolTraineeSummaries.to_attributes(@funding_upload)
    missing_urns = Funding::LeadSchoolTraineeSummariesImporter.call(attributes: attributes)
    raise("Lead school URNs: #{missing_urns.join(', ')} not found") unless missing_urns.blank?
  end
end
