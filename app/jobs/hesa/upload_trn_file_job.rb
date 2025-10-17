# frozen_string_literal: true

module Hesa
  class UploadTrnFileJob < ApplicationJob
    queue_as :hesa

    def perform
      return unless FeatureService.enabled?(:hesa_trn_requests)

      trainees = Trainee.imported_from_hesa
                        .where.not(trn: nil) # some trainees could still be waiting for their TRN from TRS
                        .where(hesa_trn_submission_id: nil)
                        .where(start_academic_cycle_id: AcademicCycle.current.id)
      payload = UploadTrnFile.call(trainees:)
      trn_submission = TrnSubmission.create(payload: payload, submitted_at: Time.zone.now)

      trainees.update_all(hesa_trn_submission_id: trn_submission.id)

      trn_submission
    rescue UploadTrnFile::TrnFileUploadError => e
      Sentry.capture_exception(e)
    end
  end
end
