# frozen_string_literal: true

module Confirmation
  module TraineeId
    class View < GovukComponent::Base
      attr_accessor :data_model

      delegate :trainee_id, to: :data_model

      def initialize(data_model:)
        @data_model = data_model
      end

      def trainee
        data_model.is_a?(Trainee) ? data_model : data_model.trainee
      end
    end
  end
end
