# frozen_string_literal: true

require "govuk/components"

module Trainees
  module RecordDetails
    class ViewPreview < ViewComponent::Preview
      def default
        render(View.new(trainee: mock_trainee("default"), last_updated_event: last_updated_event))
      end

      def with_no_trainee_id
        render(View.new(trainee: mock_trainee(nil), last_updated_event: last_updated_event))
      end

      def with_deferred_status
        render(View.new(trainee: mock_trainee("deferred", :deferred), last_updated_event: last_updated_event))
      end

      def with_withdrawn_status
        render(View.new(trainee: mock_trainee("withdrawn", :withdrawn), last_updated_event: last_updated_event))
      end

    private

      def mock_trainee(trainee_id, state = :draft)
        @mock_trainee ||= Trainee.new(
          id: 1,
          training_route: TRAINING_ROUTE_ENUMS[:assessment_only],
          trainee_id: trainee_id,
          created_at: Time.zone.today,
          state: state,
          submitted_for_trn_at: Time.zone.today,
          defer_date: state == :deferred ? Time.zone.today : nil,
          withdraw_date: state == :withdrawn ? Time.zone.today : nil,
        )
      end

      def last_updated_event
        OpenStruct.new(date: Time.zone.today)
      end
    end
  end
end
