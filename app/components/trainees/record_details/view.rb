# frozen_string_literal: true

module Trainees
  module RecordDetails
    class View < GovukComponent::Base
      include SanitizeHelper
      include SummariesHelper

      attr_reader :trainee

      def initialize(trainee)
        @trainee = trainee
        @not_provided_copy = I18n.t("components.confirmation.not_provided")
      end

      def trainee_id
        trainee.trainee_id.presence || @not_provided_copy
      end

      def submission_date
        render_text_with_hint(Time.zone.yesterday)
      end

      def last_updated_date
        render_text_with_hint(trainee.updated_at)
      end

    private

      def render_text_with_hint(date)
        hint_text = tag.span(time_ago_in_words(date).concat(" ago"), class: "govuk-hint")

        sanitize(tag.p(date_for_summary_view(date), class: "govuk-body") + hint_text)
      end
    end
  end
end
