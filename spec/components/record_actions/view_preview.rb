# frozen_string_literal: true

require "govuk/components"

module RecordActions
  class ViewPreview < ViewComponent::Preview
    def trn_requested_or_received
      trainee.state = %i[submitted_for_trn trn_received].sample
      render View.new(trainee)
    end

    def deferred
      trainee.state = :deferred
      render View.new(trainee)
    end

  private

    def trainee
      @trainee ||= Trainee.new(id: 1)
    end
  end
end
