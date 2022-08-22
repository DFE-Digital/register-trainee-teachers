# frozen_string_literal: true

module Dqt
  class SyncStateJob < ApplicationJob
    sidekiq_options retry: 0
    queue_as :default

    AWARDED = "Pass"

    def perform(trainee)
      return unless FeatureService.enabled?(:integrate_with_dqt) && trainee.trn_received?

      response = Dqt::RetrieveTeacher.call(trainee: trainee)
      dqt_state = response.dig("initial_teacher_training", "result")

      return unless dqt_state == AWARDED

      awarded_at = response.dig("qualified_teacher_status", "qts_date")

      return if awarded_at.blank?

      trainee.awarded_at = awarded_at
      trainee.state = "awarded"

      Trainees::SetAcademicCyclesJob.perform_later(trainee)
    end

  private

    attr_reader :trainee
  end
end
