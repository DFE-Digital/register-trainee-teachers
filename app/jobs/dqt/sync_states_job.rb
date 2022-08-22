# frozen_string_literal: true

module Dqt
  class SyncStatesJob < ApplicationJob
    sidekiq_options retry: 0
    queue_as :default

    AWARDED = "Pass"

    def perform(number_of_trainees = 100)
      return unless FeatureService.enabled?(:integrate_with_dqt)

      # DQT have a validation on length of TRN
      trainees = Trainee.trn_received.imported_from_hesa.where("length(trn) = 7").limit(number_of_trainees)

      trainees.each do |trainee|
        response = Dqt::RetrieveTeacher.call(trainee: trainee)
        dqt_state = response.dig("initial_teacher_training", "result")

        next unless dqt_state == AWARDED

        awarded_at = response.dig("qualified_teacher_status", "qts_date")
        # Some awarded trainees in DQT don't have a QTS date
        next if awarded_at.blank?

        Trainees::Update.call(trainee: trainee, params: { state: "awarded", awarded_at: awarded_at }, update_dqt: false)
      ensure
        sleep(0.1)
      end
    end
  end
end
