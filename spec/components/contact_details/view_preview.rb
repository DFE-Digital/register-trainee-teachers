# frozen_string_literal: true

require "govuk/components"

module ContactDetails
  class ViewPreview < ViewComponent::Preview
    def with_email
      render(View.new(data_model: mock_trainee))
    end

    def without_email
      render(View.new(data_model: Trainee.new(id: 2)))
    end

  private

    def mock_trainee
      @mock_trainee ||= Trainee.new(
        id: 1,
        email: "Paddington@bear.com",
      )
    end
  end
end
