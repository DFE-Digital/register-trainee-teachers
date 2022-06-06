# frozen_string_literal: true

module FundingHelper
  def training_initiative_options
    (ROUTE_INITIATIVES_ENUMS.values - ["no_initiative"]).sort
  end

  def funding_options(trainee)
    cannot_start_funding?(trainee) ? :funding_inactive : :funding_active
  end

  def format_currency(amount)
    number_to_currency(
      amount,
      unit: "£",
      locale: :en,
      strip_insignificant_zeros: true,
    )
  end

  def funding_csv_export_path(funding_type, organisation)
    return polymorphic_path([:funding, funding_type], format: :csv) unless current_user.system_admin?

    path_prefix = organisation.is_a?(School) ? :lead_school : :provider

    polymorphic_path([path_prefix, :funding, funding_type], format: :csv)
  end

private

  def cannot_start_funding?(trainee)
    return true if trainee.early_years_route? && trainee.academic_cycle.nil?

    funding_manager = FundingManager.new(trainee)
    funding_manager.funding_available? && trainee.course_subject_one.blank?
  end
end
