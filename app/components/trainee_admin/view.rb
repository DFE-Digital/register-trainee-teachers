# frozen_string_literal: true

module TraineeAdmin
  class View < ViewComponent::Base
    attr_reader :trainee

    def initialize(trainee)
      @trainee = trainee
    end
  end
end
