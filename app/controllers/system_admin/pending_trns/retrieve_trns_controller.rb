# frozen_string_literal: true

module SystemAdmin
  module PendingTrns
    class RetrieveTrnsController < BaseController
      before_action :check_for_trn_request

      def update
        trn = Dqt::RetrieveTrn.call(trn_request:)

        if trn
          trainee.trn_received!(trn)
          trn_request.received!
          redirect_to(pending_trns_path, flash: { success: "TRN successfully retrieved for #{trainee_name(trainee)}" })
        else
          redirect_to(pending_trns_path, flash: { warning: "TRN still not available for #{trainee_name(trainee)}" })
        end
      rescue Dqt::Client::HttpError => e
        redirect_to(pending_trns_path, dqt_error: "DQT error: #{e.inspect}")
      end

    private

      def check_for_trn_request
        return if trn_request

        redirect_to(pending_trns_path, flash: { warning: "#{trainee.full_name} has no TRN request (it may have been manually deleted)." })
      end
    end
  end
end
