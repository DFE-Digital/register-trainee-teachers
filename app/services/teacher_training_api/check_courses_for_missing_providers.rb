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
      provider_codes = Provider.kept.pluck(:code)

      Course.where(recruitment_cycle_year:).where.not(accredited_body_code: provider_codes)
    end

    def message
      return "There are no courses with missing providers for recruitment cycle year #{recruitment_cycle_year}." unless courses_with_missing_providers.count.positive?

      return "There is 1 course with a missing provider for recruitment cycle year #{recruitment_cycle_year}." if courses_with_missing_providers.count == 1

      "There are #{courses_with_missing_providers.count} courses with missing providers for recruitment cycle year #{recruitment_cycle_year}."
    end

    def message_with_missing_provider_codes
      return message unless courses_with_missing_providers.count.positive?

      provider_codes = courses_with_missing_providers.pluck(:accredited_body_code).uniq

      return message + " The missing provider code is #{provider_codes.first}." if provider_codes.count == 1

      message + " The missing provider codes are #{provider_codes.join(', ')}."
    end
  end
end
