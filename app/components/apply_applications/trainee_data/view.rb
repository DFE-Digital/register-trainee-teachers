# frozen_string_literal: true

module ApplyApplications
  module TraineeData
    class View < GovukComponent::Base
      include ApplicationHelper
      include TraineeHelper

      attr_reader :trainee, :form

      def initialize(trainee, form)
        @trainee = trainee
        @form = form
        @apply_invalid_data_view = ApplyInvalidDataView.new(trainee.apply_application)
      end
    end
  end
end
