# frozen_string_literal: true

module FlashBanner
  class View < GovukComponent::Base
    attr_reader :flash, :trainee, :referer

    FLASH_TYPES = %i[success warning info].freeze

    def initialize(flash:, trainee:, referer:)
      @flash = flash
      @trainee = trainee
      @referer = referer
    end

    def display?
      flash.any? && (non_draft_trainee? || degree_deleted?)
    end

  private

    def non_draft_trainee?
      !trainee&.draft?
    end

    def degree_deleted?
      referer&.include?("degrees/confirm") && non_draft_trainee?
    end
  end
end
