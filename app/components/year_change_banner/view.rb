# frozen_string_literal: true

module YearChangeBanner
  class View < ApplicationComponent
    DEFAULT_ACADEMIC_CYCLE_START_DATE = "1 August"

    def initialize
      @today = Time.zone.today
    end

    def render?
      july? || august?
    end

    def title
      if july?
        "The #{current_year} to #{current_year + 1} academic year will start on #{cycle_start_date}"
      elsif august?
        "The #{current_year} to #{current_year + 1} academic year started on #{cycle_start_date}"
      end
    end

    def content
      if july?
        "<a class=\"govuk-notification-banner__link\" href=\"#{dates_and_deadlines_guidance_path}\">View dates and deadlines</a> for the upcoming academic year.".html_safe
      elsif august?
        "<a class=\"govuk-notification-banner__link\" href=\"#{dates_and_deadlines_guidance_path}\">View dates and deadlines</a> for this academic year.".html_safe
      end
    end

  private

    def july?
      current_month == 7
    end

    def august?
      current_month == 8
    end

    def current_month
      @today.month
    end

    def current_year
      @today.year
    end

    def cycle_start_date
      @cycle_start_date ||= AcademicCycle.current&.start_date&.to_fs(:govuk_no_year) || DEFAULT_ACADEMIC_CYCLE_START_DATE
    end
  end
end
