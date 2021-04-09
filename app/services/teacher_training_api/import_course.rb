# frozen_string_literal: true

module TeacherTrainingApi
  class ImportCourse
    include ServicePattern

    # For full list, see https://api.publish-teacher-training-courses.service.gov.uk/api-reference.html#schema-courseattributes
    IMPORTABLE_STATES = %w[
      empty
      rolled_over
      published
      published_with_unpublished_changes
      withdrawn
    ].freeze

    def initialize(provider:, course:)
      @provider = provider
      @attrs = course["attributes"].symbolize_keys
    end

    def call
      return unless IMPORTABLE_STATES.include?(attrs[:state])
      return if further_education_level_course?

      course.update!(name: attrs[:name],
                     start_date: start_date,
                     level: attrs[:level],
                     age_range: age_range,
                     qualification: qualification,
                     duration_in_years: duration_in_years,
                     course_length: attrs[:course_length],
                     subjects: subjects,
                     route: route,
                     summary: attrs[:summary])
    end

  private

    attr_reader :provider, :attrs

    def further_education_level_course?
      attrs[:level] == "further_education"
    end

    def subjects
      Subject.where(code: attrs[:subject_codes])
    end

    def start_date
      Time.strptime(attrs[:start_date], "%B %Y")
    end

    def qualification
      attrs[:qualifications].sort.join("_with_")
    end

    def age_range
      age_minimum, age_maximum = attrs.values_at(:age_minimum, :age_maximum)
      age_maximum = 19 if age_maximum == 18 # DTTP doesn't have an entity with 18
      "#{age_minimum} to #{age_maximum} course"
    end

    def duration_in_years
      case attrs[:course_length]
      when "OneYear" then 1
      when "TwoYears" then 2
      else 1
      end
    end

    def route
      routes = {
        higher_education_programme: :provider_led_postgrad,
        pg_teaching_apprenticeship: :pg_teaching_apprenticeship,
        school_direct_salaried_training_programme: :school_direct_salaried,
        school_direct_training_programme: :school_direct_tuition_fee,
        scitt_programme: :provider_led_postgrad,
      }

      routes[attrs[:program_type].to_sym]
    end

    def course
      @course ||= provider.courses.find_or_initialize_by(code: attrs[:code])
    end
  end
end
