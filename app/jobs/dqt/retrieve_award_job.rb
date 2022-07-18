# frozen_string_literal: true

module Dqt
  class RetrieveAwardJob < ApplicationJob
    sidekiq_options retry: 0
    queue_as :default
    retry_on Client::HttpError

    class TraineeAttributeError < StandardError; end

    def perform(trainee)
      return unless FeatureService.enabled?(:integrate_with_dqt)

      response = Dqt::RetrieveTeacher.call(trainee: trainee)
      awarded_at = response.dig("qualified_teacher_status", "qts_date")
      Trainees::Update.call(trainee: trainee, params: { awarded_at: awarded_at }, update_dtq: false) if awarded_at
    end

  private

    attr_reader :trainee
  end
end
