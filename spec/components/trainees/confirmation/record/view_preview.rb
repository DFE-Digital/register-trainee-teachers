# frozen_string_literal: true

require "govuk/components"
module Trainees
  module Confirmation
    module Record
      class ViewPreview < ViewComponent::Preview
        def default
          render(Trainees::Confirmation::Record::View.new(trainee: mock_trainee))
        end

        def with_no_data
          render(Trainees::Confirmation::Record::View.new(trainee: Trainee.new(id: 2)))
        end

      private

        def mock_trainee
          @mock_trainee ||= Trainee.new(
            id: 1,
            record_type: :assessment_only,
            trainee_id: "ABC-1234-XYZ",
          )
        end
      end
    end
  end
end
