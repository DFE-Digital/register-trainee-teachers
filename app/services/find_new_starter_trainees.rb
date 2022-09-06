# frozen_string_literal: true

class FindNewStarterTrainees
  attr_reader :census_date

  def initialize(census_date)
    @census_date = census_date
  end

  def call
    trainees = Trainee.where("itt_start_date <= :date or trainee_start_date <= :date", date: census_date)
                      .or(Trainee.where(trainee_start_date: nil))
                      .where(start_academic_cycle_id: AcademicCycle.current)
                      .not_draft

    Trainees::Filter.call(trainees: trainees, filters: nil)
  end
end
