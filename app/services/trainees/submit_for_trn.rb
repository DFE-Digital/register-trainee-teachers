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
      Dttp::RegisterForTrnJob.perform_later(trainee, dttp_id)
      Dttp::RetrieveTrnJob.perform_with_default_delay(trainee)
    end

  private

    attr_reader :trainee, :dttp_id
  end
end
