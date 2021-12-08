# frozen_string_literal: true

module RecordDetails
  class TraineeStartDate
    include SummaryHelper
    include Rails.application.routes.url_helpers

    def initialize(trainee)
      @trainee = trainee
    end

    def text
      return I18n.t("record_details.view.itt_has_not_started").html_safe if trainee.starts_course_in_the_future?
      return I18n.t("record_details.view.deferred_before_itt_started").html_safe if deferred_with_no_start_date?
      return date_for_summary_view(trainee.commencement_date) if commencement_date_present?

      I18n.t("record_details.view.not_provided")
    end

    def link
      return if trainee.starts_course_in_the_future?
      return edit_trainee_start_date_path(trainee) if deferred_with_no_start_date? || commencement_date_present?

      edit_trainee_start_status_path(trainee)
    end

    def course_empty?
      trainee.itt_start_date.nil?
    end

  private

    attr_reader :trainee

    def commencement_date_present?
      trainee.commencement_date.present?
    end

    def deferred_with_no_start_date?
      trainee.deferred? && trainee.commencement_date.blank?
    end
  end
end
