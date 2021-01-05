# frozen_string_literal: true

module Trainees
  module RecordActions
    class View < GovukComponent::Base
      include ApplicationHelper

      attr_reader :trainee

      def initialize(trainee)
        @trainee = trainee
      end

      def display_actions?
        allow_defer? || allow_withdraw?
      end

      def allow_defer?
        trainee.submitted_for_trn? || trainee.trn_received?
      end

      def allow_withdraw?
        allow_defer? || trainee.deferred?
      end

      def defer_and_withdraw_links
        return defer_link + " or " + withdraw_link if choose_both_actions?
        return defer_link if allow_defer?
        return reinstate_link + " or " + withdraw_link if allow_withdraw?
      end

    private

      def choose_both_actions?
        allow_defer? && allow_withdraw?
      end

      def defer_link
        govuk_link_to t("views.trainees.edit.defer"), trainee_deferral_path(@trainee), class: "defer"
      end

      def withdraw_link
        govuk_link_to t("views.trainees.edit.withdraw"), trainee_withdrawal_path(@trainee), class: "withdraw"
      end

      def reinstate_link
        govuk_link_to t("view.trainees.edit.reinstate"), trainees_path, class: "reinstate"
      end
    end
  end
end
