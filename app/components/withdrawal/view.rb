# frozen_string_literal: true

module Withdrawal
  class View < GovukComponent::Base
    include SummaryHelper

    attr_accessor :trainee, :editable, :has_errors, :show_link

    def initialize(trainee:, link: true, has_errors: false, editable: false)
      @trainee = trainee
      @link = link
      @has_errors = has_errors
      @editable = editable
      @show_link = show_link?(link)
    end

  private

    def withdrawal_rows
      [
        date_row,
        reason_row,
        details_row,
      ]
    end

    def date_row
      mappable_field("date", @trainee.withdraw_date.strftime(Date::DATE_FORMATS[:govuk]))
    end

    def reason_row
      mappable_field("reason", @trainee.withdraw_reason&.humanize)
    end

    def details_row
      mappable_field("details", @trainee.additional_withdraw_reason)
    end

    def row_name(name)
      I18n.t("components.withdrawal.rows.#{name}")
    end

    def mappable_field(name, value)
      { field_label: row_name(name), field_value: value }
    end

    def summary_title
      I18n.t("components.withdrawal.title")
    end

    def show_link?(link)
      return false unless editable

      link
    end
  end
end
