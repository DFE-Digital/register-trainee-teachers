# frozen_string_literal: true

module Trainees
  class SetSlugSentAt
    include ServicePattern

    def initialize(trainee:)
      @trainee = trainee
    end

    def call
      trainee.update!(slug_sent_to_trs_at: Time.zone.now)
    end

  private

    attr_reader :trainee
  end
end
