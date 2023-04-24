# frozen_string_literal: true

class UndoWithdrawalForm
  include ActiveModel::Model

  attr_accessor :comment, :ticket, :trainee, :session

  validates :comment, presence: true
  validates :ticket, format: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: true

  def initialize(trainee: nil, comment: nil, ticket: nil, session: nil)
    @trainee = trainee
    @session = session
    @comment = comment || session[:undo_withdrawal_comment]
    @ticket = ticket || session[:undo_withdrawal_ticket]
    session[:undo_withdrawal_comment] = @comment
    session[:undo_withdrawal_ticket] = @ticket
  end

  def save
    return false unless valid?

    trainee.update(
      state: previous_state,
      withdraw_reason: nil,
      additional_withdraw_reason: nil,
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
        .reject { |hash| hash.dig("state", 1) == 4 }
        &.last&.dig("state")&.last || 2 # default to trn_received
  end
end
