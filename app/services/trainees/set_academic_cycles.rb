# frozen_string_literal: true

module Trainees
  class SetAcademicCycles
    include ServicePattern

    DURATIONS = %w[hours months days years].freeze

    def initialize(trainee:)
      @trainee = trainee
    end

    def call
      trainee.start_academic_cycle = start_academic_cycle
      trainee.end_academic_cycle = end_academic_cycle
      trainee
    end

  private

    attr_reader :trainee

    delegate :commencement_date, :itt_start_date, :awarded_at,
             :withdraw_date, :itt_end_date, :hesa_metadatum, :training_route,
             to: :trainee

    def start_academic_cycle
      start_date.present? ? AcademicCycle.for_date(start_date) : AcademicCycle.current
    end

    def end_academic_cycle
      AcademicCycle.for_date(end_date) if end_date.present?
    end

    def start_date
      commencement_date || itt_start_date
    end

    def end_date
      awarded_at || withdraw_date || itt_end_date || start_date_plus_duration
    end

    def start_date_plus_duration
      return unless start_date

      if course_duration > 5.years
        raise("Trainee id: #{trainee.id}, slug: #{trainee.slug} has a course length greater than five years")
      end

      start_date + course_duration
    end

    def course_duration
      actual_course_duration || estimated_course_duration
    end

    def actual_course_duration
      return unless [course_duration_unit, course_duration_amount].all?(&:present?)

      course_duration_amount.public_send(course_duration_unit)
    end

    def course_duration_amount
      hesa_metadatum&.study_length
    end

    def course_duration_unit
      hesa_metadatum&.study_length_unit if DURATIONS.include?(hesa_metadatum&.study_length_unit)
    end

    def estimated_course_duration
      return 3.years if UNDERGRAD_ROUTES.include?(training_route)
      return 2.years if trainee.part_time?

      1.year
    end
  end
end
