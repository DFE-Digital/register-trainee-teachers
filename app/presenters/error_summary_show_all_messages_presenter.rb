# frozen_string_literal: true

class ErrorSummaryShowAllMessagesPresenter
  def initialize(error_messages)
    @error_messages = error_messages
  end

  def formatted_error_messages
    @error_messages
      .flat_map do |attribute, messages|
        messages.map { |message| [attribute, message] }
      end
  end
end
