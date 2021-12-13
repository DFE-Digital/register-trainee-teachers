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

    def missing_fields
      trainee.state = :submitted_for_trn
      render View.new(trainee, has_missing_fields: true)
    end

    def itt_starts_in_future
      trainee.state = :submitted_for_trn
      trainee.itt_start_date = Time.zone.tomorrow
      render View.new(trainee)
    end

  private

    def trainee
      @trainee ||= Trainee.new(id: 1)
    end
  end
end
