# frozen_string_literal: true

module Dqt
  class SyncTeacherJob < Dqt::BaseJob
    queue_as :dqt_sync

    def perform(trainee)
      return unless FeatureService.enabled?("dqt_import.sync_teachers")

      Dqt::SyncTeacher.call(trainee:)
    end
  end
end
