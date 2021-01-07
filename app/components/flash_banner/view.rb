# frozen_string_literal: true

module FlashBanner
  class View < GovukComponent::Base
    attr_reader :flash

    def initialize(flash:)
      @flash = flash
    end

  private

    def flash_types
      %w[warning info success]
    end
  end
end
