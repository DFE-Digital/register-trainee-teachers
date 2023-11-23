# frozen_string_literal: true

module PlacementQuery
  extend ActiveSupport::Concern

  def trainees_to_be_placed
    previous_cycle = AcademicCycle.previous

    trainees
      .where(end_academic_cycle_id: previous_cycle.id, state: :awarded)
      .where.not(awarded_at: nil)
      .includes(:placements)
      .select { |trainee| trainee.placements.size < 2 }
  end
end
