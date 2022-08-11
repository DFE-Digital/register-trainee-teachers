# frozen_string_literal: true

module Trainees
  class SetAcademicCycles
    include ServicePattern

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

    delegate :commencement_date,
             :itt_start_date,
             :awarded_at,
             :withdraw_date,
             :itt_end_date, to: :trainee

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
      awarded_at || withdraw_date || itt_end_date || CalculateIttEndDate.call(trainee: trainee)
    end
  end
end
