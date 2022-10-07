# frozen_string_literal: true

module Hesa
  class UploadTrnFileJob < ApplicationJob
    def perform
      return unless FeatureService.enabled?(:hesa_trn_requests)

      trainees = Trainee.imported_from_hesa
                        .where.not(trn: nil) # some trainees could still be waiting for their TRN from DQT
                        .where(hesa_trn_submission_id: nil)
      payload = UploadTrnFile.call(trainees: trainees)
      TrnSubmission.create(payload: payload, submitted_at: Time.zone.now)
    rescue UploadTrnFile::TrnFileUploadError => e
      Sentry.capture_exception(e)
    end
  end
end
