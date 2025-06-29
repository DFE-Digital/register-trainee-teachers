# frozen_string_literal: true

module FundingHelper
  def training_initiative_options(trainee)
    available_training_initiatives_for_cycle(trainee).sort
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

  def available_training_initiatives_for_cycle(trainee)
    return [] if trainee.start_academic_cycle.blank?

    year = trainee.start_academic_cycle.start_year
    find_initiatives_for_year(year)
  end

  def find_initiatives_for_year(year)
    constant_name = "TRAINING_INITIATIVES_#{year}_TO_#{year + 1}"
    return Object.const_get(constant_name) if Object.const_defined?(constant_name)

    []
  end
end
