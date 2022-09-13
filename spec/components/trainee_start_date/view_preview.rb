# frozen_string_literal: true

require "govuk/components"

module TraineeStartDate
  class ViewPreview < ViewComponent::Preview
    def default
      render(View.new(data_model: mock_trainee))
    end

  private

    def mock_trainee
      @mock_trainee ||= Trainee.new(trainee_start_date: Time.zone.today)
    end
  end
end
