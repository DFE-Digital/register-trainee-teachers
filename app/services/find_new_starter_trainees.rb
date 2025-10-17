# frozen_string_literal: true

class FindNewStarterTrainees
  EXCLUDED_ROUTES = [
    TRAINING_ROUTE_ENUMS[:assessment_only],
    TRAINING_ROUTE_ENUMS[:early_years_assessment_only],
  ].freeze

  attr_reader :census_date

  def initialize(census_date)
    @census_date = census_date
  end

  def call
    trainees = Trainee.where("itt_start_date <= :date or trainee_start_date <= :date", date: census_date)
                      .or(Trainee.where(trainee_start_date: nil))
                      .where(start_academic_cycle_id: AcademicCycle.current)
                      .where.not(training_route: EXCLUDED_ROUTES)
                      .not_draft

    Trainees::Filter.call(
      trainees: trainees,
      filters: {
        not_withdrawn_before: AcademicCycle.current.second_wednesday_of_october,
      },
    )
  end
end
