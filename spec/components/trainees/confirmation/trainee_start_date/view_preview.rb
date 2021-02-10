# frozen_string_literal: true

require "govuk/components"

module Trainees
  module Confirmation
    module TraineeStartDate
      class ViewPreview < ViewComponent::Preview
        def default
          render(Trainees::Confirmation::TraineeStartDate::View.new(trainee: mock_trainee))
        end

      private

        def mock_trainee
          @mock_trainee ||= Trainee.new(commencement_date: Time.zone.today)
        end
      end
    end
  end
end
