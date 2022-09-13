# frozen_string_literal: true

module WithdrawalDetails
  class View < GovukComponent::Base
    include SummaryHelper

    attr_reader :data_model, :deferred, :trainee

    def initialize(data_model)
      @data_model = data_model
      @trainee = data_model.trainee
      @deferred = data_model.trainee.deferred?
    end

    def trainee_start_date
      date_for_summary_view(data_model.trainee_start_date)
    end

    def withdraw_date
      deferred ? date_with_deferral_text : withdrawal_date
    end

    def withdraw_reason
      return data_model.additional_withdraw_reason if data_model.withdraw_reason == WithdrawalReasons::FOR_ANOTHER_REASON

      I18n.t("components.confirmation.withdrawal_details.reasons.#{data_model.withdraw_reason}")
    end

    def rows
      [start_date_row, withdrawal_date_row, reason_for_withdrawal_row]
    end

  private

    def date_with_deferral_text
      I18n.t("components.confirmation.withdrawal_details.withdrawal_date", date: withdrawal_date)
    end

    def withdrawal_date
      date_for_summary_view(data_model.date)
    end

    def start_date_row
      {
        key: t("components.confirmation.withdrawal_details.trainee_start_date_label"),
        value: trainee_start_date,
        action_href: deferred ? nil : trainee_start_date_verification_path(data_model.trainee, context: :withdraw),
        action_text: deferred ? nil : t(:change),
      }
    end

    def withdrawal_date_row
      {
        key: t("components.confirmation.withdrawal_details.withdraw_date_label"),
        value: withdraw_date,
        action_href: deferred ? nil : trainee_withdrawal_path(data_model.trainee),
        action_text: deferred ? nil : t(:change),
      }
    end

    def reason_for_withdrawal_row
      {
        key: t("components.confirmation.withdrawal_details.withdraw_reason_label"),
        value: withdraw_reason,
        action_href: trainee_withdrawal_path(data_model.trainee),
        action_text: t(:change),
      }
    end
  end
end
