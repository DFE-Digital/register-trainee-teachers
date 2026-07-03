# frozen_string_literal: true

module Wizards
  class FundingStepWizard
    include Rails.application.routes.url_helpers

    def initialize(trainee:, page_tracker: nil)
      @trainee = trainee
      @page_tracker = page_tracker
      @funding_manager ||= FundingManager.new(trainee)
    end

    def next_step
      origin_page_or_next_step
    end

  private

    attr_reader :trainee, :page_tracker, :funding_manager

    def origin_page_or_next_step
      return trainee_funding_confirm_path(trainee) if user_came_from_confirm_or_trainee_page?

      redirect_url
    end

    def user_came_from_confirm_or_trainee_page?
      page_tracker.last_origin_page_path&.include?("funding/confirm") || page_tracker.last_origin_page_path == "/trainees/#{trainee.slug}"
    end

    def redirect_url
      funding_manager.can_apply_for_funding_type? ? edit_trainee_funding_bursary_path(trainee) : trainee_funding_confirm_path(trainee)
    end
  end
end
