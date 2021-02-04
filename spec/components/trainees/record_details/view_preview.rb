# frozen_string_literal: true

require "govuk/components"

module Trainees
  module RecordDetails
    class ViewPreview < ViewComponent::Preview
      def default
        render(Trainees::RecordDetails::View.new(mock_trainee("default")))
      end

      def with_no_trainee_id
        render(Trainees::RecordDetails::View.new(mock_trainee(nil)))
      end

      def with_deferred_status
        render(Trainees::RecordDetails::View.new(mock_trainee("deferred", :deferred)))
      end

      def with_withdrawn_status
        render(Trainees::RecordDetails::View.new(mock_trainee("withdrawn", :withdrawn)))
      end

    private

      def mock_trainee(trainee_id, state = :draft)
        @mock_trainee ||= Trainee.new(
          id: 1,
          record_type: :assessment_only,
          trainee_id: trainee_id,
          created_at: Time.zone.today,
          updated_at: Time.zone.today,
          state: state,
          defer_date: state == :deferred ? Time.zone.today : nil,
          withdraw_date: state == :withdrawn ? Time.zone.today : nil,
        )
      end
    end
  end
end
