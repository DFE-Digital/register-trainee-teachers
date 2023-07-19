# frozen_string_literal: true

module Trainees
  class SetSlugSentAt
    include ServicePattern

    def initialize(trainee:)
      @trainee = trainee
    end

    def call
      trainee.slug_sent_to_dqt_at ||= Time.zone.now
      trainee.save!
    end

  private

    attr_reader :trainee
  end
end
