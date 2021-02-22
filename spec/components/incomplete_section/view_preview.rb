# frozen_string_literal: true

module IncompleteSection
  class ViewPreview < ViewComponent::Preview
    def default
      render IncompleteSection::View.new(title: "title", link_text: "link_text", url: "url")
    end

    def error
      render IncompleteSection::View.new(title: "title", link_text: "link_text", url: "url", error: true)
    end
  end
end
