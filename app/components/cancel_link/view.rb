# frozen_string_literal: true

module CancelLink
  class View < GovukComponent::Base
    include TraineeHelper

    attr_reader :draft

    def initialize(trainee)
      @trainee = trainee
    end

    def render?
      !@trainee.draft?
    end

  private

    attr_reader :trainee
  end
end
