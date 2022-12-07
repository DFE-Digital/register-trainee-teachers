# frozen_string_literal: true

module Dqt
  class SyncTraineeTrnJob < ApplicationJob
    queue_as :dqt_sync
    retry_on Client::HttpError

    class Error < StandardError; end

    def perform(trainee_id)
      return unless FeatureService.enabled?(:integrate_with_dqt)

      trainee = Trainee.find(trainee_id)
      response = Dqt::FindTeacher.call(trainee:)

      if response["trn"].present?
        trainee.trn_received!(response["trn"])
      else
        raise(Error, "No TRN found in DQT for trainee: #{trainee.id}")
      end
    end
  end
end
