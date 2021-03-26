# frozen_string_literal: true

module Trainees
  module Confirmation
    module WithdrawalDetails
      class View < GovukComponent::Base
        include SummaryHelper

        attr_reader :data_model

        def initialize(data_model)
          @data_model = data_model
        end

        def withdraw_date
          date_for_summary_view(data_model.date)
        end

        def withdraw_reason
          return data_model.additional_withdraw_reason if data_model.withdraw_reason == WithdrawalReasons::FOR_ANOTHER_REASON

          I18n.t("components.confirmation.withdrawal_details.reasons.#{data_model.withdraw_reason}")
        end
      end
    end
  end
end
