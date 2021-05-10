# frozen_string_literal: true

module Trainees
  module ApplyTraineeData
    class View < GovukComponent::Base
      include ApplicationHelper
      include TraineeHelper

      attr_reader :trainee, :form

      def initialize(trainee, form)
        @trainee = trainee
        @form = form
      end
    end
  end
end
