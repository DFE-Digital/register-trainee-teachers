# frozen_string_literal: true

module FilteredBackLink
  class View < GovukComponent::Base
    attr_reader :link_text, :href

    def initialize(href:, text: nil)
      @href = href
      @link_text = text || t("views.all_records")
    end

    def link_href
      Tracker.new(session: session, href: href).get_path
    end
  end
end
