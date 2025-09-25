# frozen_string_literal: true

module ConfirmTraineeDelete
  class View < ApplicationComponent
    attr_reader :trainee, :delete_reason, :ticket

    def initialize(trainee:, delete_reason: nil, ticket: nil)
      @trainee = trainee
      @delete_reason = delete_reason
      @ticket = ticket
    end

    def record_detail_rows
      [
        status_row,
        reason_row,
        ticket_row,
      ]
    end

  private

    def status_row
      {
        field_label: "New record status",
        field_value: '<strong class="govuk-tag govuk-tag--red">Deleted</strong>'.html_safe,
      }
    end

    def reason_row
      {
        field_label: "Reason for deletion",
        field_value: delete_reason,
        action_url: edit_trainee_deletions_reason_path(trainee),
      }
    end

    def ticket_row
      {
        field_label: "Zendesk ticket URL",
        field_value: ticket.presence || "Not provided",
        action_url: edit_trainee_deletions_reason_path(trainee),
      }
    end
  end
end
