# frozen_string_literal: true

module Withdrawal
  class View < ViewComponent::Base
    include SanitizeHelper

    def initialize(data_model:, editable: false, undo_withdrawal: false)
      @data_model = data_model
      @undo_withdrawal = undo_withdrawal
      @editable = editable
      @deferred = trainee.deferred?
    end

    def trainee
      data_model.is_a?(Trainee) ? data_model : data_model.trainee
    end

    def rows
      @rows ||= [
        start_date,
        withdraw_date_from_course,
        withdrawal_trigger,
        reasons,
        future_interest_in_teaching,
      ].compact
    end

  private

    attr_accessor :data_model, :editable, :undo_withdrawal, :deferred

    def start_date
      mappable_field(
        data_model.trainee_start_date&.strftime(Date::DATE_FORMATS[:govuk]) || "-",
        "Trainee start date",
        (trainee_start_date_verification_path(trainee, context: :withdraw) unless deferred),
      )
    end

    def withdraw_date_from_course
      mappable_field(
        withdraw_date&.strftime(Date::DATE_FORMATS[:govuk]) || "-",
        "Date the trainee withdrew",
        edit_trainee_withdrawal_date_path(trainee),
      )
    end

    def withdraw_date
      if data_model.is_a?(Trainee)
        data_model.trainee_withdrawals&.last&.date
      else
        data_model.withdraw_date
      end
    end

    def withdrawal_trigger
      mappable_field(
        t("views.forms.withdrawal_trigger.#{trigger}.label", default: "-"),
        "How the trainee withdrew",
        edit_trainee_withdrawal_trigger_path(trainee),
      )
    end

    def trigger
      if data_model.is_a?(Trainee)
        data_model.trainee_withdrawals&.last&.trigger
      else
        data_model.trigger
      end
    end

    def reasons
      mappable_field(
        reasons_html_safe,
        "Why the trainee withdrew",
        edit_trainee_withdrawal_reason_path(trainee),
      )
    end

    def reasons_html_safe
      return unless withdrawal_reasons

      withdrawal_reasons.map do |reason|
        return another_reason if reason.name.match?("another_reason")

        t("components.withdrawal_details.reasons.#{reason.name}", default: "-")
      end.join("<br>").html_safe
    end

    def withdrawal_reasons
      if data_model.is_a?(Trainee)
        data_model.trainee_withdrawals&.last&.withdrawal_reasons
      else
        data_model.withdrawal_reasons
      end
    end

    def future_interest_in_teaching
      mappable_field(
        t("views.forms.withdrawal_future_interest.#{future_interest}.label", default: "-"),
        "Future interest in teaching",
        edit_trainee_withdrawal_future_interest_path(trainee),
      )
    end

    def future_interest
      if data_model.is_a?(Trainee)
        data_model.trainee_withdrawals&.last&.future_interest
      else
        data_model.future_interest
      end
    end

    def another_reason
      if data_model.is_a?(Trainee)
        data_model.trainee_withdrawals&.last&.another_reason
      else
        data_model.another_reason
      end
    end

    def details_dfe_label
      if data_model.withdraw_reasons_dfe_details.blank?
        "Could the Department for Education have done anything to avoid the candidate withdrawing?"
      else
        "What the Department for Education could have done"
      end
    end

    def mappable_field(field_value, field_label, action_url)
      { field_value:, field_label:, action_url: }
    end
  end
end
