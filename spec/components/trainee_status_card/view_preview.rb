# frozen_string_literal: true

module TraineeStatusCard
  class ViewPreview < ViewComponent::Preview
    class MockTrainees
      def where(*)
        OpenStruct.new(count: Array(1..100).sample)
      end
    end

    award_states = %w[qts_recommended qts_received eyts_recommended eyts_received]

    (Trainee.states.keys + award_states).each do |state|
      define_method state.to_s do
        render(TraineeStatusCard::View.new(state: state, target: Rails.application.routes.url_helpers.trainees_path("state[]": state), count: Array(1..1000).sample))
      end
    end
  end
end
