# frozen_string_literal: true

module FlashBanner
  class View < ApplicationComponent
    attr_reader :flash, :trainee

    FLASH_TYPES = %i[success warning info].freeze

    def initialize(flash:, trainee:)
      @flash = flash
      @trainee = trainee
    end

    def display?
      flash.any? && (non_draft_trainee? || degree_deleted? || placement_deleted?)
    end

  private

    def non_draft_trainee?
      !trainee&.draft?
    end

    def degree_deleted?
      auditable = trainee.associated_audits.last
      auditable&.auditable_type == "Degree" && auditable&.action == "destroy"
    end

    def placement_deleted?
      auditable = trainee.associated_audits.last
      auditable&.auditable_type == "Placement" && auditable&.action == "destroy"
    end
  end
end
