# frozen_string_literal: true

module Trainees
  module RecordDetails
    class View < GovukComponent::Base
      include SanitizeHelper
      include SummaryHelper

      attr_reader :trainee, :last_updated_event, :not_provided_copy

      def initialize(trainee:, last_updated_event:)
        @trainee = trainee
        @last_updated_event = last_updated_event
        @not_provided_copy = I18n.t("components.confirmation.not_provided")
      end

      def trainee_id
        trainee.trainee_id.presence || not_provided_copy
      end

      def trainee_start_date
        trainee.commencement_date.present? ? date_for_summary_view(trainee.commencement_date) : not_provided_copy
      end

      def submission_date
        render_text_with_hint(trainee.submitted_for_trn_at)
      end

      def last_updated_date
        render_text_with_hint(last_updated_event.date)
      end

      def trn_row
        if trainee.trn.present?
          {
            key: "TRN",
            value: trainee.trn,
          }
        else
          {
            key: "Submitted for TRN",
            value: submission_date,
          }
        end
      end

      def trainee_progress_row
        return unless trainee.recommended_for_award? || trainee.awarded?

        {
          key: trainee.award_type,
          value: render(StatusTag::View.new(trainee: trainee, classes: "govuk-!-margin-bottom-2")) + tag.br + progress_date,
        }
      end

      def trainee_status_row
        return unless trainee.deferred? || trainee.withdrawn?

        {
          key: "Trainee status",
          value: render(StatusTag::View.new(trainee: trainee, classes: "govuk-!-margin-bottom-2")) + tag.br + status_date,
        }
      end

    private

      def render_text_with_hint(date)
        hint_text = tag.span(time_ago_in_words(date).concat(" ago"), class: "govuk-hint")

        sanitize(tag.p(date_for_summary_view(date), class: "govuk-body") + hint_text)
      end

      def progress_date
        return unless trainee_progress_date

        I18n.t("components.record_details.progress_date_prefix.#{trainee.state}") + date_for_summary_view(trainee_progress_date)
      end

      def status_date
        return unless trainee_status_date

        I18n.t("components.record_details.status_date_prefix.#{trainee.state}") + date_for_summary_view(trainee_status_date)
      end

      def trainee_progress_date
        {
          recommended_for_award: trainee.recommended_for_award_at,
          awarded: trainee.awarded_at,
        }[trainee.state.to_sym]
      end

      def trainee_status_date
        {
          deferred: trainee.defer_date,
          withdrawn: trainee.withdraw_date,
        }[trainee.state.to_sym]
      end
    end
  end
end
