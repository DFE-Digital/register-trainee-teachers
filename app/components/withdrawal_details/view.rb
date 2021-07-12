# frozen_string_literal: true

module WithdrawalDetails
  class View < GovukComponent::Base
    include SummaryHelper

    attr_reader :data_model, :deferred

    def initialize(data_model)
      @data_model = data_model
      @deferred = data_model.trainee.deferred?
    end

    def withdraw_date
      deferred ? date_with_deferral_text : withdrawal_date
    end

    def withdraw_reason
      return data_model.additional_withdraw_reason if data_model.withdraw_reason == WithdrawalReasons::FOR_ANOTHER_REASON

      I18n.t("components.confirmation.withdrawal_details.reasons.#{data_model.withdraw_reason}")
    end

  private

    def date_with_deferral_text
      I18n.t("components.confirmation.withdrawal_details.withdrawal_date", date: withdrawal_date)
    end

    def withdrawal_date
      date_for_summary_view(data_model.date)
    end
  end
end
