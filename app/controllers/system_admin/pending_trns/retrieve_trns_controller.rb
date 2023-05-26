# frozen_string_literal: true

module SystemAdmin
  module PendingTrns
    class RetrieveTrnsController < BaseController
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
    end
  end
end
