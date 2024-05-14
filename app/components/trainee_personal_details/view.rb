# frozen_string_literal: true

module TraineePersonalDetails
  class View < ViewComponent::Base
    attr_reader :trainee

    def initialize(trainee)
      @trainee = trainee
    end
  end
end
