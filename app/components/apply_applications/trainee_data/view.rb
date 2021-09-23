# frozen_string_literal: true

module ApplyApplications
  module TraineeData
    class View < GovukComponent::Base
      include ApplicationHelper
      include TraineeHelper

      attr_reader :form, :invalid_data_view

      def initialize(trainee_data_form:)
        @form = trainee_data_form
        @invalid_data_view = ApplyInvalidDataView.new(trainee.apply_application)
      end

      delegate :trainee, to: :form
    end
  end
end
