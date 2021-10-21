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

    def initialize(course_data:, provider_data:)
      @course_data = course_data
      @provider_data = provider_data
      @course_attributes = course_data[:attributes]
    end

    def call
      return unless IMPORTABLE_STATES.include?(course_attributes[:state])
      return if further_education_level_course? || invalid_age_range?

      course.update!(
        name: course_attributes[:name],
        code: course_attributes[:code],
        start_date: start_date,
        level: course_attributes[:level],
        qualification: qualification,
        min_age: course_attributes[:age_minimum],
        max_age: course_attributes[:age_maximum],
        duration_in_years: duration_in_years,
        course_length: course_attributes[:course_length],
        subjects: subjects,
        route: route,
        summary: course_attributes[:summary],
        study_mode: course_attributes[:study_mode],
        accredited_body_code: accredited_body_code,
        recruitment_cycle_year: Settings.current_recruitment_cycle_year,
      )
    end

  private

    attr_reader :course_data, :provider_data, :course_attributes

    def further_education_level_course?
      course_attributes[:level] == "further_education"
    end

    def invalid_age_range?
      course_attributes.values_at(:age_minimum, :age_maximum).include?(nil)
    end

    def subjects
      codes = course_attributes[:subject_codes]
      # It's critical that the ordering of course.subjects ends up matching the order of
      # course_attributes[:subject_codes] because first subject will determine if the
      # trainee is entitled to a bursary (see Trainees::Funding::BursariesController#load_bursary_info!).
      #
      # By ordering it correctly here, ActiveRecord will create the association records in the same order,
      # and then we just need to add the scope order("course_subjects.id") to Course#subjects.
      Subject.where(code: codes).sort_by { |subject| codes.index(subject.code) }
    end

    def start_date
      Time.strptime(course_attributes[:start_date], "%B %Y")
    end

    def qualification
      course_attributes[:qualifications].sort.join("_with_")
    end

    def duration_in_years
      course_attributes[:course_length] == "TwoYears" ? 2 : 1
    end

    def route
      routes = {
        higher_education_programme: :provider_led_postgrad,
        pg_teaching_apprenticeship: :pg_teaching_apprenticeship,
        school_direct_salaried_training_programme: :school_direct_salaried,
        school_direct_training_programme: :school_direct_tuition_fee,
        scitt_programme: :provider_led_postgrad,
      }

      routes[course_attributes[:program_type].to_sym]
    end

    def accredited_body_code
      course_attributes[:accredited_body_code] || find_accredited_body_code
    end

    def find_accredited_body_code
      provider = provider_data&.find { |p| p[:id] == course_data[:relationships][:provider][:data][:id] }
      provider[:attributes][:code] if provider
    end

    def course
      @course ||= Course.find_or_initialize_by(uuid: course_attributes[:uuid])
    end
  end
end
