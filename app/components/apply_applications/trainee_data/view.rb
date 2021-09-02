# frozen_string_literal: true

module ApplyApplications
  module TraineeData
    class View < GovukComponent::Base
      include ApplicationHelper
      include TraineeHelper

      attr_reader :data_model, :form, :invalid_data_view

      def initialize(data_model)
        @data_model = data_model[:data_model] || data_model
        @form = TraineeDataForm.new(trainee)
        @invalid_data_view = ApplyInvalidDataView.new(trainee.apply_application)
      end

      def trainee
        data_model.is_a?(Trainee) ? data_model : data_model.trainee
      end
    end
  end
end
