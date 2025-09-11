# frozen_string_literal: true

module NoticeBanner
  class View < ApplicationComponent
    renders_one :header

    def initialize; end

    def render?
      content.present?
    end
  end
end
