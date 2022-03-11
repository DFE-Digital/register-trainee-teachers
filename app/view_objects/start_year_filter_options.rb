# frozen_string_literal: true

class StartYearFilterOptions
  class << self
    def render(user:, draft:)
      new.render(user: user, draft: draft)
    end
  end

  def render(user:, draft:)
    @user = user
    @draft = draft

    formatted_start_years
  end

private

  attr_reader :user, :draft

  def formatted_start_years
    academic_cycles_with_an_in_scope_trainee.map(&:start_year).map do |start_year|
      if current_academic_cycle_year?(start_year)
        "#{start_year} to #{start_year + 1} (current year)"
      else
        "#{start_year} to #{start_year + 1}"
      end
    end
  end

  def current_academic_cycle_year?(year)
    AcademicCycle.for_date(Time.zone.now).start_year == year
  end

  def academic_cycles_with_an_in_scope_trainee
    @academic_cycles_with_an_in_scope_trainee ||= AcademicCycle.order(start_date: :desc).select do |cycle|
      scope = TraineePolicy::Scope.new(user, cycle.trainees_starting).resolve
      scope = draft ? scope.draft : scope.not_draft
      scope.any?
    end
  end
end
