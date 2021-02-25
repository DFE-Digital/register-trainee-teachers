# frozen_string_literal: true

module TraineeStatusCard
  class ViewPreview < ViewComponent::Preview
    class MockTrainees
      def where(*)
        OpenStruct.new(count: Array(1..100).sample)
      end
    end

    Trainee.states.keys.each do |state|
      define_method state.to_s do
        render(TraineeStatusCard::View.new(state: state, target: Rails.application.routes.url_helpers.trainees_path("state[]": state), trainees: MockTrainees.new))
      end
    end
  end
end
