# frozen_string_literal: true

module NoticeBanner
  class View < GovukComponent::Base
    renders_one :header

    # rubocop:disable Style/RedundantInitialize
    def initialize; end
    # rubocop:enable Style/RedundantInitialize

    def render?
      content.present?
    end
  end
end
