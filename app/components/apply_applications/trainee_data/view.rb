# frozen_string_literal: true

module ApplyApplications
  module TraineeData
    class View < ApplicationComponent
      include ApplicationHelper
      include TraineeHelper

      attr_reader :form, :invalid_data_view, :editable

      def initialize(trainee_data_form:, editable: false)
        @form = trainee_data_form
        @editable = editable
        @invalid_data_view = InvalidTraineeDataView.new(trainee, trainee_data_form)
      end

      delegate :trainee, to: :form
    end
  end
end
