# frozen_string_literal: true

module Withdrawal
  class View < GovukComponent::Base
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
        withdraw_date,
        reasons,
        details,
        details_dfe,
      ]
    end

  private

    attr_accessor :data_model, :editable, :undo_withdrawal, :deferred

    def start_date
      mappable_field(
        trainee.trainee_start_date.strftime(Date::DATE_FORMATS[:govuk]),
        "Trainee start date",
        (trainee_start_date_verification_path(trainee, context: :withdraw) unless deferred)
      )
    end

    def withdraw_date
      mappable_field(
        data_model.withdraw_date.strftime(Date::DATE_FORMATS[:govuk]),
        "Date the trainee withdrew",
        edit_trainee_withdrawal_date_path(trainee)
      )
    end

    def reasons
      mappable_field(
        reasons_html_safe,
        "Why the trainee withdrew",
        edit_trainee_withdrawal_reason_path(trainee)
      )
    end

    def reasons_html_safe
      data_model.withdrawal_reasons.map do |reason|
        t("components.withdrawal_details.reasons.#{reason.name}")
      end.join("<br>").html_safe
    end

    def details
      mappable_field(
        data_model.withdraw_reasons_details,
        "Details of why the trainee withdrew",
        edit_trainee_withdrawal_extra_information_path(trainee)
      )
    end

    def details_dfe
      mappable_field(
        data_model.withdraw_reasons_dfe_details,
        "What the Department for Education could have done",
        edit_trainee_withdrawal_extra_information_path(trainee)
      )
    end

    def mappable_field(field_value, field_label, action_url)
      { field_value:, field_label:, action_url: }
    end
  end
end
