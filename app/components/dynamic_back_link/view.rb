# frozen_string_literal: true

module DynamicBackLink
  class View < GovukComponent::Base
    attr_reader :trainee, :text

    def initialize(trainee, text: nil)
      @trainee = trainee
      @text = text
    end

    def link_text
      text.presence || (trainee.draft? ? t("back_to_draft") : t("back_to_record"))
    end

    def path
      PageTracker.new(trainee_slug: trainee.slug, session: session, request: request).previous_page_path
    end
  end
end
