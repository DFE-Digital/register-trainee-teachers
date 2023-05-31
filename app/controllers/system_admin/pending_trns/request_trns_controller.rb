# frozen_string_literal: true

module SystemAdmin
  module PendingTrns
    class RequestTrnsController < BaseController
      def update
        trn_request.destroy!

        trn_request = Dqt::RegisterForTrnJob.perform_now(trainee.reload)

        if trn_request.failed?
          redirect_to(pending_trns_path, flash: { warning: "TRN request failed for #{trainee_name(trainee)}" })
        else
          redirect_to(pending_trns_path, flash: { success: "TRN requested successfully for #{trainee_name(trainee)}" })
        end
      rescue Dqt::Client::HttpError => e
        redirect_to(pending_trns_path, dqt_error: "DQT error: #{e.inspect}")
      end
    end
  end
end
