# frozen_string_literal: true

module RecordHeader
  class View < GovukComponent::Base
    include TraineeHelper

    attr_reader :trainee

    def initialize(trainee:)
      @trainee = trainee
    end

    delegate :trn, to: :trainee

    def show_trn?
      trn.present?
    end
  end
end
