# frozen_string_literal: true

require "govuk/components"

module Trainees
  module RecordActions
    class ViewPreview < ViewComponent::Preview
      def trn_requested_or_received
        trainee.state = %i[submitted_for_trn trn_received].sample
        render Trainees::RecordActions::View.new(trainee)
      end

      def deferred
        trainee.state = :deferred
        render Trainees::RecordActions::View.new(trainee)
      end

    private

      def trainee
        @trainee ||= Trainee.new(id: 1)
      end
    end
  end
end
