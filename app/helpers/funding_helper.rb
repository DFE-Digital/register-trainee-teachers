# frozen_string_literal: true

module FundingHelper
  HIDDEN_TRAINING_INITIATIVES_BY_START_YEAR = {
    2026 => %w[international_relocation_payment],
  }.freeze

  def training_initiative_options(trainee)
    cycle = trainee.start_academic_cycle
    initiatives = Funding::AvailableTrainingInitiativesService.call(academic_cycle: cycle)
    hidden = hidden_training_initiatives(cycle) - [trainee.training_initiative].compact
    (initiatives - hidden).sort
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

  def hidden_training_initiatives(academic_cycle)
    HIDDEN_TRAINING_INITIATIVES_BY_START_YEAR.fetch(academic_cycle&.start_year, [])
  end
end
