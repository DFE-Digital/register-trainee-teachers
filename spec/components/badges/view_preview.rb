# frozen_string_literal: true

module Badges
  class ViewPreview < ViewComponent::Preview
    # rake example_data:generate must be run before
    # viewing these component previews

    def with_no_trainees_in_award_states
      trainees = Trainee.where.not(state: %i[awarded recommended_for_award])
      render(Badges::View.new(trainees))
    end

    def with_trainees_only_in_eyts_states
      trainees = Trainee.where(training_route: EARLY_YEARS_ROUTES)
      render(Badges::View.new(trainees))
    end

    def with_trainees_only_in_qts_states
      trainees = Trainee.where.not(training_route: EARLY_YEARS_ROUTES)
      render(Badges::View.new(trainees))
    end

    def with_trainees_in_qts_and_eyts_states
      trainees = Trainee.all
      render(Badges::View.new(trainees))
    end

    def with_no_trainees
      trainees = Trainee.none
      render(Badges::View.new(trainees))
    end
  end
end
