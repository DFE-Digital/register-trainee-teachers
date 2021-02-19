# frozen_string_literal: true

module DynamicBackLink
  class View < GovukComponent::Base
    attr_reader :trainee, :text, :last_origin_page

    def initialize(trainee, text: nil, last_origin_page: false)
      @trainee = trainee
      @text = text
      @last_origin_page = last_origin_page
    end

    def link_text
      text.presence || (trainee.draft? ? t("back_to_draft") : t("back_to_record"))
    end

    def path
      page_tracker = PageTracker.new(trainee_slug: trainee.slug, session: session, request: request)
      page_tracker.public_send(last_origin_page ? :last_origin_page_path : :previous_page_path)
    end
  end
end
