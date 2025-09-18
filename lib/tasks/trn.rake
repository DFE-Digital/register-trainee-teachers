# frozen_string_literal: true

namespace :trn do
  desc "Resubmit for TRN trainees with submitted for TRN status"
  task resubmit: :environment do
    trainees = Trainee
      .includes(:dqt_trn_request)
      .submitted_for_trn
      .undiscarded
      .where(dqt_trn_request: { id: nil })

    trainees.find_each do |trainee|
      if FeatureService.enabled?(:integrate_with_trs)
        Trs::RegisterForTrnJob.perform_later(trainee.reload)
      else
        raise(StandardError, "No integration is enabled")
      end
    end
  end
end
