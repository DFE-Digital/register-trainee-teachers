# frozen_string_literal: true

class UndoWithdrawalForm
  include ActiveModel::Model

  attr_accessor :comment, :ticket, :trainee, :session

  validates :comment, presence: true

  def initialize(trainee:, session:, comment: nil, ticket: nil)
    @trainee = trainee
    @session = session
    @comment = comment || session[:undo_withdrawal_comment]
    @ticket = ticket || session[:undo_withdrawal_ticket]
    session[:undo_withdrawal_comment] = @comment
    session[:undo_withdrawal_ticket] = @ticket
  end

  def save
    return false unless valid?

    trainee.current_withdrawal.discard!

    trainee.update(
      state: previous_state,
      withdraw_reasons_details: nil,
      withdraw_reasons_dfe_details: nil,
      withdraw_date: nil,
      audit_comment: audit_comment,
    )
    delete!
  end

  def previous_state
    @previous_state ||= Trainee.states.key(previous_state_enum)
  end

  def delete!
    session.delete(:undo_withdrawal_comment)
    session.delete(:undo_withdrawal_ticket)
  end

private

  def audit_comment
    [comment, ticket].compact.join("\n")
  end

  def previous_state_enum
    @previous_state_enum ||=
      trainee
        .audits
        .where(action: :update)
        .pluck(:audited_changes)
        .reject { |hash| hash.dig("state", 1) == Trainee.states["withdrawn"] }
        &.last&.dig("state")&.last || Trainee.states["trn_received"] # default to trn_received
  end
end
