# frozen_string_literal: true

module Dqt
  class SyncTraineeTrnJob < ApplicationJob
    queue_as :default
    retry_on Client::HttpError

    class Error < StandardError; end

    def perform(trainee)
      return unless FeatureService.enabled?(:integrate_with_dqt)

      teacher = Dqt::FindTeacher.call(trainee: trainee)

      if teacher["trn"].present?
        Trainees::Update.call(
          trainee: trainee,
          params: { trn: teacher["trn"] },
          update_dqt: false,
        )
      else
        raise(
          Error,
          "No TRN found in DQT for trainee: #{trainee.id}",
        )
      end
    end
  end
end
