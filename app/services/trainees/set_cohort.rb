# frozen_string_literal: true

module Trainees
  class SetCohort
    include ServicePattern

    def initialize(trainee:)
      @trainee = trainee
    end

    def call
      return trainee if trainee.itt_start_date.nil?
      return trainee if trainee_is_current? && trainee.current!
      return trainee if trainee_is_future? && trainee.future!
      return trainee if trainee_is_past? && trainee.past!

      trainee
    end

  private

    attr_reader :trainee

    def trainee_is_current?
      starts_in_the_current_academic_cycle? ||
        withdrawn_in_the_current_cycle? ||
        trainee.deferred?
    end

    def trainee_is_future?
      trainee.itt_start_date > current_academic_cycle.end_date
    end

    def trainee_is_past?
      trainee.itt_end_date < current_academic_cycle.start_date &&
        (
          awarded_before_the_current_cycle? ||
          withdrawn_before_the_current_cycle?
        )
    end

    def current_academic_cycle
      @current_academic_cycle ||= AcademicCycle.current
    end

    def awarded_before_the_current_cycle?
      trainee.awarded? && trainee.awarded_at < current_academic_cycle.start_date
    end

    def withdrawn_before_the_current_cycle?
      trainee.withdrawn? && trainee.withdraw_date < current_academic_cycle.start_date
    end

    def starts_in_the_current_academic_cycle?
      trainee.itt_start_date >= current_academic_cycle.start_date &&
        trainee.itt_start_date <= current_academic_cycle.end_date
    end

    def withdrawn_in_the_current_cycle?
      trainee.withdrawn? &&
        trainee.withdraw_date >= current_academic_cycle.start_date
    end
  end
end
