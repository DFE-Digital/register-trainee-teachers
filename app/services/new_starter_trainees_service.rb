# frozen_string_literal: true

class NewStarterTraineesService
  def initialize(census_date)
    @census_date = census_date
  end

  def call
    trainees = Trainee.where("itt_start_date <= :date or commencement_date <= :date", date: census_date)
                      .or(Trainee.where(commencement_date: nil))
                      .where(start_academic_cycle_id: AcademicCycle.current)
                      .not_draft

    Trainees::Filter.call(trainees: trainees, filters: nil)
  end

  attr_reader :census_date
end
