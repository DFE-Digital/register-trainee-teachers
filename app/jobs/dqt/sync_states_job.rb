# frozen_string_literal: true

module Dqt
  class SyncStatesJob < ApplicationJob
    sidekiq_options retry: 0
    queue_as :default

    RATE_LIMIT = 300

    def perform(number_of_trainees = 100)
      return unless FeatureService.enabled?(:integrate_with_dqt)

      # DQT have a validation on length of TRN
      trainees = Trainee.trn_received.imported_from_hesa.where("length(trn) = 7").limit(number_of_trainees)

      trainees.find_each do |trainee|
        Dqt::SyncState.call(trainee: trainee)
      ensure
        sleep(60 / RATE_LIMIT)
      end
    end
  end
end
