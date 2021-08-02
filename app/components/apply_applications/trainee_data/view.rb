# frozen_string_literal: true

module ApplyApplications
  module TraineeData
    class View < GovukComponent::Base
      include ApplicationHelper
      include TraineeHelper

      attr_reader :trainee, :form, :invalid_data_view

      def initialize(trainee, form)
        @trainee = trainee
        @form = form
        @invalid_data_view = ApplyInvalidDataView.new(trainee.apply_application)
      end

    private

      def invalid_data?
        if trainee.invalid_apply_data?
          ApplyInvalidDataView.new(trainee.apply_application)
        end
      end
    end
  end
end
