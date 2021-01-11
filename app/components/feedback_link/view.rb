# frozen_string_literal: true

module FeedbackLink
  class View < GovukComponent::Base
    attr_reader :feedback_link_url, :enabled

    def initialize(enabled: true, feedback_link_url:)
      @enabled = enabled
      @feedback_link_url = feedback_link_url
    end
  end
end
