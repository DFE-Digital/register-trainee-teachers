# frozen_string_literal: true

class AcademicYearFilterOptions
  def initialize(user:, draft:)
    @user = user
    @draft = draft
  end

  def formatted_years(cycle_context)
    compute_academic_cycles(cycle_context).map do |academic_cycle|
      start_year = academic_cycle.start_date.year
      end_year = academic_cycle.end_date.year
      if current_academic_cycle_year?(start_year)
        "#{start_year} to #{end_year} (current year)"
      else
        "#{start_year} to #{end_year}"
      end
    end
  end

private

  attr_reader :user, :draft

  def current_academic_cycle_year?(year)
    AcademicCycle.current&.start_year == year
  end

  def compute_academic_cycles(cycle_context)
    scope = TraineePolicy::Scope.new(user, Trainee.public_send(draft ? :draft : :not_draft)).resolve
    academic_cycle_column_id_name = "#{cycle_context.to_s.split('_').first}_academic_cycle_id"
    academic_cycle_ids = scope.distinct.pluck(academic_cycle_column_id_name).compact
    AcademicCycle.order(start_date: :desc).where(id: academic_cycle_ids)
  end
end
