# frozen_string_literal: true

module Trainees
  module Confirmation
    module TraineeStartDate
      class View < GovukComponent::Base
        attr_accessor :trainee

        def initialize(trainee:)
          @trainee = trainee
        end

        def start_date
          trainee.commencement_date&.strftime("%d %B %Y")
        end
      end
    end
  end
end
