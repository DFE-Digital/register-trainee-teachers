# frozen_string_literal: true

module FundingHelper
  def training_initiative_options(trainee)
    Funding::AvailableTrainingInitiativesService.call(trainee:).sort
  end

  def funding_options(trainee)
    can_start_funding_section?(trainee) ? :funding_active : :funding_inactive
  end

  def format_currency(amount)
    number_to_currency(
      amount,
      unit: "£",
      locale: :en,
      strip_insignificant_zeros: true,
    )
  end

  def funding_csv_export_path(funding_type)
    return polymorphic_path([:funding, funding_type], format: :csv) unless current_user.system_admin?

    polymorphic_path([:provider, :funding, funding_type], format: :csv)
  end

private

  def can_start_funding_section?(trainee)
    trainee.progress.course_details && trainee.start_academic_cycle.present?
  end
end
