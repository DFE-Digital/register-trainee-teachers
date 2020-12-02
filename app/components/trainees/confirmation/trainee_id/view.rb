# frozen_string_literal: true

module Trainees
  module Confirmation
    module TraineeId
      class View < GovukComponent::Base
        attr_accessor :trainee

        def initialize(trainee:)
          @trainee = trainee
        end

        def trainee_id
          trainee.trainee_id.presence || I18n.t("components.confirmation.not_provided")
        end
      end
    end
  end
end
