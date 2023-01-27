# frozen_string_literal: true

module DatesHelper
  def date_before_itt_start_date?(trainee_start_date, itt_start_date)
    return false if itt_start_date.blank?

    trainee_start_date < itt_start_date
  end

  def valid_date?(date_args)
    Date.valid_date?(*date_args) && date_args.all?(&:positive?)
  end

  def end_date_required?
    trainee.hesa_id.blank?
  end

  def end_date_not_required?
    !end_date_required?
  end

  def end_date_not_provided?
    [end_year, end_month, end_day].any?(&:blank?)
  end
end
