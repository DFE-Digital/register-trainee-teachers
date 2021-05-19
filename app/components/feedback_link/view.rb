# frozen_string_literal: true

module FeedbackLink
  class View < GovukComponent::Base
    attr_reader :feedback_link_url, :enabled, :feedback_type_text

    def initialize(enabled: true, feedback_link_url:, feedback_type_text:)
      @enabled = enabled
      @feedback_link_url = feedback_link_url
      @feedback_type_text = feedback_type_text
    end
  end
end
