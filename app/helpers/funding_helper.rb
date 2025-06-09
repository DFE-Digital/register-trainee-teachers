# frozen_string_literal: true

module FundingHelper
  def training_initiative_options(trainee = nil)
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

  def available_training_initiatives_for_cycle(trainee = nil)
    @available_training_initiatives_for_cycle ||= {}
    
    academic_year = get_academic_year(trainee)
    
    @available_training_initiatives_for_cycle[academic_year] ||= find_initiatives_for_year(academic_year)
  end

  def get_academic_year(trainee)
    if trainee&.start_academic_cycle.present?
      trainee.start_academic_cycle.start_year
    else
      Settings.current_recruitment_cycle_year
    end
  end

  def find_initiatives_for_year(year)
    # Start with the specified year and work backwards
    earliest_supported_year = 2020
    (year.downto(earliest_supported_year)).each do |check_year|
      constant_name = "TRAINING_INITIATIVES_#{check_year}_TO_#{check_year + 1}"
      return Object.const_get(constant_name) if Object.const_defined?(constant_name)
    end
    
    # If no initiatives found, return an empty array
    []
  end
end
