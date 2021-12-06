# frozen_string_literal: true

module CommencementDateHelpers
  def commencement_date_valid
    if [day, month, year].all?(&:blank?)
      errors.add(:commencement_date, :blank)
    elsif !commencement_date.is_a?(Date)
      errors.add(:commencement_date, :invalid)
    elsif commencement_date < 10.years.ago
      errors.add(:commencement_date, :too_old)
    elsif commencement_date.future?
      errors.add(:commencement_date, :future)
    elsif trainee.course_end_date.present? && commencement_date > trainee.course_end_date
      errors.add(
        :commencement_date,
        I18n.t(
          "activemodel.errors.models.trainee_start_status_form.attributes.commencement_date.not_after_course_end_date_html",
          course_end_date: trainee.course_end_date.strftime("%-d %B %Y"),
        ).html_safe,
      )
    end
  end
end
