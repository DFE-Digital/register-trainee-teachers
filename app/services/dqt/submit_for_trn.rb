# frozen_string_literal: true
module Dqt
  class SubmitForTrn
    include ServicePattern

    def initialize(trainee:)
      @trainee = trainee
    end

    def call
      trainee.submit_for_trn!
      Dqt::RegisterForTrnJob.perform_later(trainee)
      Dqt::RetrieveTrnJob.perform_with_default_delay(trainee)
    end

    private

    attr_reader :trainee, :dttp_id
  end
end
