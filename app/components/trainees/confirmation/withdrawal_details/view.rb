# frozen_string_literal: true

module Trainees
  module Confirmation
    module WithdrawalDetails
      class View < GovukComponent::Base
        include SummaryHelper

        attr_reader :trainee

        def initialize(trainee:)
          @trainee = trainee
        end

        def confirm_section_title
          I18n.t("components.confirmation.withdrawal_details.heading")
        end

        def withdraw_date
          date_for_summary_view(trainee.withdraw_date)
        end

        def withdraw_reason
          return trainee.additional_withdraw_reason if trainee.withdraw_reason == WithdrawalReasons::FOR_ANOTHER_REASON

          I18n.t("components.confirmation.withdrawal_details.reasons.#{trainee.withdraw_reason}")
        end
      end
    end
  end
end
