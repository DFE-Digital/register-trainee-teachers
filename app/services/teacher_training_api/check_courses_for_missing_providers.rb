# frozen_string_literal: true

module TeacherTrainingApi
  class CheckCoursesForMissingProviders
    include ServicePattern

    attr_reader :recruitment_cycle_year

    def initialize(recruitment_cycle_year: Settings.current_recruitment_cycle_year)
      @recruitment_cycle_year = recruitment_cycle_year
    end

    def call
      {
        recruitment_cycle_year: recruitment_cycle_year,
        courses_with_missing_provider_count: courses_with_missing_providers.count,
        message: message_with_missing_provider_codes,
      }
    end

  private

    def courses_with_missing_providers
      Course.where(
        recruitment_cycle_year:,
      ).where(
        "NOT EXISTS (:accredited_provider)",
        accredited_provider: Provider.kept.where("code = courses.accredited_body_code"),
      )
    end

    def message
      return "[#{Rails.env}] Course Provider Checker Results #{Time.zone.now.to_fs(:govuk_date_and_time)} for #{recruitment_cycle_year}:\nNo courses with missing providers for recruitment cycle year." unless courses_with_missing_providers.count.positive?

      "[#{Rails.env}] Course Provider Checker Results #{Time.zone.now.to_fs(:govuk_date_and_time)} for #{recruitment_cycle_year}:\n#{courses_with_missing_providers.count} #{'course'.pluralize(courses_with_missing_providers.count)} with a missing provider for recruitment cycle year."
    end

    def message_with_missing_provider_codes
      return message unless courses_with_missing_providers.count.positive?

      provider_codes = courses_with_missing_providers.pluck(:accredited_body_code).uniq

      message + "\nMissing provider #{'code'.pluralize(provider_codes.count)}: #{provider_codes.join(', ')}."
    end
  end
end
