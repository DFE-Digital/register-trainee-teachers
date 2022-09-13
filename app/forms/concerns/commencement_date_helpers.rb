# frozen_string_literal: true

module CommencementDateHelpers
  def trainee_start_date_valid
    if [day, month, year].all?(&:blank?)
      errors.add(:trainee_start_date, :blank)
    elsif !trainee_start_date.is_a?(Date)
      errors.add(:trainee_start_date, :invalid)
    elsif trainee_start_date < 10.years.ago
      errors.add(:trainee_start_date, :too_old)
    elsif trainee_start_date.future?
      errors.add(:trainee_start_date, :future)
    elsif trainee.itt_end_date.present? && trainee_start_date > trainee.itt_end_date
      errors.add(
        :trainee_start_date,
        I18n.t(
          "activemodel.errors.models.trainee_start_status_form.attributes.trainee_start_date.not_after_itt_end_date_html",
          itt_end_date: trainee.itt_end_date.strftime("%-d %B %Y"),
        ).html_safe,
      )
    end
  end
end
