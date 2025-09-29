# frozen_string_literal: true

module Trainees
  class SubmitForTrn
    include ServicePattern

    def initialize(trainee:)
      @trainee = trainee
      @trs_enabled = FeatureService.enabled?(:integrate_with_trs)
    end

    def call
      check_for_conflicting_integrations

      trainee.submit_for_trn!

      if trs_enabled
        Trs::RegisterForTrnJob.perform_later(trainee)
      end
    end

  private

    attr_reader :trainee, :trs_enabled
  end
end
