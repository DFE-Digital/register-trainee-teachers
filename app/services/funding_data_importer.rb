class FundingDataImporter
  def initialize(csv_path, first_predicted_month_index)
    @csv_path = csv_path
    @first_predicted_month_index = first_predicted_month_index
  end

  def import_data
    csv_filename = File.basename(@csv_path)
    case csv_filename
    when /SDS_subject_breakdown/
      import_provider_payment_schedules
    when /SDS_Profile/
      import_lead_school_payment_schedules
    when /TB_summary_upload/
      import_provider_trainee_summaries
    when /TB_Profile/
      import_lead_school_trainee_summaries
    else
      # Handle the case when the file name doesn't match any pattern
    end
  end

  private

  def import_provider_payment_schedules
    attributes = Funding::Parsers::ProviderPaymentSchedules.to_attributes(file_path: @csv_path)
    missing_ids = Funding::ProviderPaymentSchedulesImporter.call(attributes: attributes, first_predicted_month_index: @first_predicted_month_index)
    raise("Provider accreditation ids: #{missing_ids.join(', ')} not found") unless missing_ids.blank?
  end

  def import_lead_school_payment_schedules
    attributes = Funding::Parsers::LeadSchoolPaymentSchedules.to_attributes(file_path: @csv_path)
    missing_urns = Funding::LeadSchoolPaymentSchedulesImporter.call(attributes: attributes, first_predicted_month_index: @first_predicted_month_index)
    raise("Lead school URNs: #{missing_urns.join(', ')} not found") unless missing_urns.blank?
  end

  def import_provider_trainee_summaries
    attributes = Funding::Parsers::ProviderTraineeSummaries.to_attributes(file_path: @csv_path)
    missing_ids = Funding::ProviderTraineeSummariesImporter.call(attributes: attributes)
    raise("Provider accreditation ids: #{missing_ids.join(', ')} not found") unless missing_ids.blank?
  end

  def import_lead_school_trainee_summaries
    attributes = Funding::Parsers::LeadSchoolTraineeSummaries.to_attributes(file_path: @csv_path)
    missing_urns = Funding::LeadSchoolTraineeSummariesImporter.call(attributes: attributes)
    raise("Lead school URNs: #{missing_urns.join(', ')} not found") unless missing_urns.blank?
  end
end
