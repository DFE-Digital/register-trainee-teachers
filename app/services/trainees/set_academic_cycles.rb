# frozen_string_literal: true

module Trainees
  class SetAcademicCycles
    include ServicePattern

    DEFAULT_CYCLE_OFFSET = 1.month

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

    delegate :trainee_start_date,
             :itt_start_date,
             :itt_end_date,
             :awarded_at,
             :withdraw_date, to: :trainee

    def start_academic_cycle
      start_date.present? ? AcademicCycle.for_date(start_date) : AcademicCycle.for_date(Time.zone.now + DEFAULT_CYCLE_OFFSET)
    end

    def end_academic_cycle
      AcademicCycle.for_date(end_date) if end_date.present?
    end

    def start_date
      trainee_start_date || itt_start_date
    end

    def end_date
      awarded_at || withdraw_date || itt_end_date || CalculateIttEndDate.call(trainee:)
    end
  end
end
