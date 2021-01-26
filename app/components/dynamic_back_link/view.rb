# frozen_string_literal: true

module DynamicBackLink
  class View < GovukComponent::Base
    attr_reader :trainee, :text

    def initialize(trainee, text: nil)
      @trainee = trainee
      @text = text
    end

    def link_text
      text.presence || (trainee.draft? ? "Back to draft record" : "Back to record")
    end

    def path
      OriginPage.new(trainee, session, request).path
    end
  end
end
