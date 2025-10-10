# frozen_string_literal: true

module Withdrawal
  class View < ApplicationComponent
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
        withdraw_date_from_course,
        withdrawal_trigger,
        reasons,
        future_interest_in_teaching,
      ].compact
    end

  private

    attr_accessor :data_model, :editable, :undo_withdrawal, :deferred

    def withdraw_date_from_course
      mappable_field(
        formatted_withdraw_date || "-",
        t("trainees.withdrawals.dates.edit.heading"),
        edit_trainee_withdrawal_date_path(trainee),
      )
    end

    def formatted_withdraw_date
      return if withdraw_date.nil?

      prefix = case withdraw_date&.to_date
        when Time.zone.today
          "Today - "
        when 1.day.ago.to_date
          "Yesterday - "
        end
      [prefix, withdraw_date&.strftime(Date::DATE_FORMATS[:govuk])].compact.join
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
        t("trainees.withdrawals.trigger.edit.heading"),
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
        t("trainees.withdrawals.reasons.edit.heading.#{trigger}"),
        edit_trainee_withdrawal_reason_path(trainee),
      )
    end

    def reasons_html_safe
      return unless withdrawal_reasons

      reasons = withdrawal_reasons.map do |reason|
        if reason.name.match?("another_reason")
          another_reason
        elsif reason.name == "safeguarding_concerns"
          [
            t("components.withdrawal_details.reasons.#{reason.name}"),
            sanitize(safeguarding_concern_reasons),
          ].compact_blank.join("<br>")
        else
          t("components.withdrawal_details.reasons.#{reason.name}", default: "-")
        end
      end.map { |reason| "<li>#{reason}</li>" }

      ["<ul class=\"app-summary-card__values-list\">", *reasons, "</ul>"].join.html_safe
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
        t("trainees.withdrawals.future_interests.edit.heading"),
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

    def safeguarding_concern_reasons
      if data_model.is_a?(Trainee)
        data_model.trainee_withdrawals&.last&.safeguarding_concern_reasons
      else
        data_model.safeguarding_concern_reasons
      end
    end

    def details_dfe_label
      "What the Department for Education could have done"
    end

    def mappable_field(field_value, field_label, action_url)
      { field_value:, field_label:, action_url: }
    end
  end
end
