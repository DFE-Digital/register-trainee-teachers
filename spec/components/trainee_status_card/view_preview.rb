# frozen_string_literal: true

module TraineeStatusCard
  class ViewPreview < ViewComponent::Preview
    STATUSES = %w[course_not_started_yet in_training awarded_this_year deferred incomplete].freeze

    STATUSES.each do |status|
      define_method status do
        render(
          TraineeStatusCard::View.new(
            status: status,
            target: "trainees_path",
            count: Array(1..100).sample,
          )
        )
      end
    end
  end
end
