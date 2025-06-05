# frozen_string_literal: true

module FundingHelper
  def training_initiative_options
    available_training_initiatives_for_cycle.sort
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

  def available_training_initiatives_for_cycle
    @available_training_initiatives_for_cycle ||= begin
      current_year = Settings.current_recruitment_cycle_year
      earliest_supported_year = 2024

      found_initiatives = nil
      (earliest_supported_year..current_year).reverse_each do |year|
        constant_name = "TRAINING_INITIATIVES_#{year}_TO_#{year + 1}"
        if Object.const_defined?(constant_name)
          found_initiatives = Object.const_get(constant_name)
          break
        end
      end

      found_initiatives || raise("No training initiatives found for any academic year between #{earliest_supported_year} and #{current_year}")
    end
  end
end
