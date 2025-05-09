# frozen_string_literal: true

module SystemAdmin
  module PendingTrns
    class RetrieveTrnsController < BaseController
      before_action :check_for_trn_request

      def update
        trn = retrieve_trn

        if trn
          trainee.trn_received!(trn)
          trn_request.received!
          redirect_to(pending_trns_path, flash: { success: "TRN successfully retrieved for #{trainee_name(trainee)}" })
        else
          redirect_to(pending_trns_path, flash: { warning: "TRN still not available for #{trainee_name(trainee)}" })
        end
      rescue Dqt::Client::HttpError, Trs::Client::HttpError => e
        redirect_to(pending_trns_path, dqt_error: "API error: #{e.inspect}")
      end

    private

      def retrieve_trn
        if FeatureService.enabled?(:integrate_with_trs)
          Trs::RetrieveTrn.call(trn_request:)
        elsif FeatureService.enabled?(:integrate_with_dqt)
          Dqt::RetrieveTrn.call(trn_request:)
        else
          raise(StandardError, "No integration is enabled")
        end
      end

      def check_for_trn_request
        return if trn_request

        redirect_to(pending_trns_path, flash: { warning: "#{trainee.full_name} has no TRN request (it may have been manually deleted)." })
      end
    end
  end
end
