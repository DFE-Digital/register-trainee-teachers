# frozen_string_literal: true

module Badges
  class ViewPreview < ViewComponent::Preview
    include FactoryBot::Syntax::Methods

    def with_no_trainees_in_award_states
      ActiveRecord::Base.transaction do
        trainee_id = create(:trainee, state: :draft).id
        render(Badges::View.new(Trainee.where(id: trainee_id)))
      end
    end

    def with_trainees_only_in_eyts_states
      ActiveRecord::Base.transaction do
        trainee_id = create(:trainee, training_route: :early_years_undergrad, state: :awarded).id
        render(Badges::View.new(Trainee.where(id: trainee_id)))
      end
    end

    def with_trainees_only_in_qts_states
      ActiveRecord::Base.transaction do
        trainee_id = create(:trainee, training_route: :assessment_only, state: :awarded).id
        render(Badges::View.new(Trainee.where(id: trainee_id)))
      end
    end

    def with_trainees_in_qts_and_eyts_states
      ActiveRecord::Base.transaction do
        trainee_ids = [
          create(:trainee, training_route: :assessment_only, state: :awarded).id,
          create(:trainee, training_route: :early_years_undergrad, state: :awarded).id,
        ]

        render(Badges::View.new(Trainee.where(id: trainee_ids)))
      end
    end

    def with_no_trainees
      trainees = Trainee.none
      render(Badges::View.new(trainees))
    end
  end
end
