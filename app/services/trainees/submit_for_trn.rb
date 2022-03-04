# frozen_string_literal: true

module Trainees
  class SubmitForTrn
    include ServicePattern

    def initialize(trainee:, dttp_id:)
      @trainee = trainee
      @dttp_id = dttp_id
    end

    def call
      trainee.submit_for_trn!

      if FeatureService.enabled?(:persist_to_dttp)
        Dttp::RegisterForTrnJob.perform_later(trainee, dttp_id)
        Dttp::RetrieveTrnJob.perform_with_default_delay(trainee)
      end

      if FeatureService.enabled?(:integrate_with_dqt)
        Dqt::RegisterForTrnJob.perform_later(trainee)
      end
    end

  private

    attr_reader :trainee, :dttp_id
  end
end
