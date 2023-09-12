# frozen_string_literal: true

module Dqt
  class SyncTeachersBatchJob < Dqt::BaseJob
    queue_as :dqt_sync

    def perform(trainee_ids)
      return unless FeatureService.enabled?("dqt_import.sync_teachers")

      Trainee.where(id: trainee_ids).find_each do |trainee|
        Dqt::SyncTeacherJob.perform_later(trainee)
      end
    end
  end
end
