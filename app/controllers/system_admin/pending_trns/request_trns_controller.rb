# frozen_string_literal: true

module SystemAdmin
  module PendingTrns
    class RequestTrnsController < BaseController
      def update
        trn_request&.destroy!

        trn_request = request_trn

        if trn_request.failed?
          redirect_to(pending_trns_path, flash: { warning: "TRN request failed for #{trainee_name(trainee)}" })
        else
          redirect_to(pending_trns_path, flash: { success: "TRN requested successfully for #{trainee_name(trainee)}" })
        end
      rescue Dqt::Client::HttpError, Trs::Client::HttpError => e
        redirect_to(pending_trns_path, dqt_error: "API error: #{e.inspect}")
      end

    private

      def request_trn
        if FeatureService.enabled?(:integrate_with_trs)
          Trs::RegisterForTrnJob.perform_now(trainee.reload)
        elsif FeatureService.enabled?(:integrate_with_dqt)
          Dqt::RegisterForTrnJob.perform_now(trainee.reload)
        else
          raise(StandardError, "No integration is enabled")
        end
      end
    end
  end
end
