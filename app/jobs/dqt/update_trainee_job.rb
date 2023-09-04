# frozen_string_literal: true

module Dqt
  class UpdateTraineeJob < Dqt::BaseJob
    sidekiq_options retry: 0
    queue_as :dqt

    VALID_STATES = %w[
      submitted_for_trn
      trn_received
      deferred
    ].freeze

    def perform(trainee)
      return unless FeatureService.enabled?(:integrate_with_dqt)

      return unless trainee_updatable?(trainee)

      TraineeUpdate.call(trainee:)
    end

  private

    def trainee_updatable?(trainee)
      VALID_STATES.include?(trainee.reload.state)
    end
  end
end
