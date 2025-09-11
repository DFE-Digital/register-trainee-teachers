# frozen_string_literal: true

module DynamicBackLink
  class View < ApplicationComponent
    attr_reader :trainee, :text, :last_origin_page, :consider_confirm_page

    def initialize(trainee, text: nil, last_origin_page: false, consider_confirm_page: true)
      @trainee = trainee
      @text = text
      @last_origin_page = last_origin_page
      @consider_confirm_page = consider_confirm_page
    end

    def link_text
      text.presence || (trainee.draft? ? t("back_to_draft") : t("back_to_record"))
    end

    def path
      page_tracker = PageTracker.new(trainee_slug: trainee.slug, session: session, request: request)
      if last_origin_page
        page_tracker.last_origin_page_path
      else
        page_tracker.previous_page_path(consider_confirm_page:)
      end
    end
  end
end
