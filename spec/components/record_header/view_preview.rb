# frozen_string_literal: true

require "govuk/components"

module RecordHeader
  class ViewPreview < ViewComponent::Preview
    def with_trn
      render(View.new(trainee: mock_trainee("0123456789")))
    end

    def with_no_trn
      render(View.new(trainee: mock_trainee(nil)))
    end

  private

    def mock_trainee(trn)
      @mock_trainee ||= Trainee.new(
        first_names: "Dave",
        middle_names: "Hendricks",
        last_name: "Smith",
        trn: trn,
      )
    end
  end
end
