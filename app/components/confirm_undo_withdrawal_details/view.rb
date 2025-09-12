# frozen_string_literal: true

module ConfirmUndoWithdrawalDetails
  class View < ApplicationComponent
    State = Struct.new(:state, :award_type)

    include SanitizeHelper
    include SummaryHelper

    attr_reader :trainee, :comment, :ticket, :editable, :state

    def initialize(trainee:, comment: nil, ticket: nil, state: nil, editable: true)
      @trainee = trainee
      @comment = comment
      @ticket = ticket
      @state = State.new(state, trainee.award_type)
      @editable = editable
    end

    def record_detail_rows
      [
        status_row,
        comment_row,
        ticket_row,
      ]
    end

  private

    def status_row
      {
        field_label: "New record status",
        field_value: render(StatusTag::View.new(trainee: state, hide_progress_tag: true)),
      }
    end

    def comment_row
      {
        field_label: "Trainee timeline comment",
        field_value: comment,
        action_url: edit_trainee_undo_withdrawal_path(trainee),
      }
    end

    def ticket_row
      {
        field_label: "Zendesk ticket URL",
        field_value: ticket,
        action_url: edit_trainee_undo_withdrawal_path(trainee),
      }
    end
  end
end
