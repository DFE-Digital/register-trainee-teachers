# frozen_string_literal: true

module BlueInsetTextWithLink
  class ViewPreview < ViewComponent::Preview
    def default
      render BlueInsetTextWithLink::View.new(title: "title", link_text: "link_text", url: "url")
    end
  end
end
