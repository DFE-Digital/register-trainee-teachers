# frozen_string_literal: true

module Trainees
  class SubmitForTrn
    include ServicePattern

    def initialize(trainee:)
      @trainee = trainee
    end

    def call
      trainee.submit_for_trn!

      if FeatureService.enabled?(:integrate_with_dqt)
        Dqt::RegisterForTrnJob.perform_later(trainee)
      end
    end

  private

    attr_reader :trainee
  end
end
