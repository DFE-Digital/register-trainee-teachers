# frozen_string_literal: true

class AcademicYearFilterOptions
  def initialize(user:, draft:)
    @user = user
    @draft = draft
  end

  def formatted_years(cycle_context)
    compute_academic_cycles(cycle_context).map do |academic_cycle|
      if academic_cycle.current?
        "#{academic_cycle.label} (current year)"
      else
        academic_cycle.label
      end
    end
  end

private

  attr_reader :user, :draft

  def compute_academic_cycles(cycle_context)
    scope = TraineePolicy::Scope.new(user, Trainee.public_send(draft ? :draft : :not_draft)).resolve
    academic_cycle_column_id_name = "#{cycle_context.to_s.split('_').first}_academic_cycle_id"
    academic_cycle_ids = scope.distinct.pluck(academic_cycle_column_id_name).compact
    AcademicCycle.order(start_date: :desc).where(id: academic_cycle_ids)
  end
end
