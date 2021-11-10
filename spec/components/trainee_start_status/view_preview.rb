# frozen_string_literal: true

require "govuk/components"

module TraineeStartStatus
  class ViewPreview < ViewComponent::Preview
    def default
      render(View.new(data_model: mock_trainee))
    end

    def with_itt_not_yet_started
      render(View.new(data_model: Trainee.new(commencement_status: :itt_not_yet_started)))
    end

  private

    def mock_trainee
      @mock_trainee ||= Trainee.new(commencement_date: Time.zone.today)
    end
  end
end
