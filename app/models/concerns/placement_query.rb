# frozen_string_literal: true

module PlacementQuery
  extend ActiveSupport::Concern

  def trainees_to_be_placed
    previous_cycle = AcademicCycle.previous

    trainees
      .where(end_academic_cycle_id: previous_cycle.id, state: :awarded)
      .where.not(awarded_at: nil)
      .joins("LEFT JOIN (SELECT trainee_id, COUNT(*) as placement_count FROM placements GROUP BY trainee_id) placements_counts ON placements_counts.trainee_id = trainees.id")
      .where("placements_counts.placement_count < 2 OR placements_counts.placement_count IS NULL")
  end
end
