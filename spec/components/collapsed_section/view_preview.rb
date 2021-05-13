# frozen_string_literal: true

module CollapsedSection
  class ViewPreview < ViewComponent::Preview
    def default
      render CollapsedSection::View.new(title: "title", link_text: "link_text", url: "url")
    end

    def error
      render CollapsedSection::View.new(title: "title", link_text: "link_text", url: "url", error: true)
    end
  end
end
