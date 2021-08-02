# frozen_string_literal: true

module CollapsedSection
  class ViewPreview < ViewComponent::Preview
    def default_with_link_only
      render CollapsedSection::View.new(title: "title", link_text: "link_text", url: "url")
    end

    def error_with_link_only
      render CollapsedSection::View.new(title: "title", link_text: "link_text", url: "url", has_errors: true)
    end

    def default_with_hint_text_only
      render CollapsedSection::View.new(title: "title", hint_text: "hint_text")
    end

    def error_with_hint_text_only
      render CollapsedSection::View.new(title: "title", hint_text: "hint_text", has_errors: true)
    end

    def default_with_link_and_hint_text
      render CollapsedSection::View.new(title: "title", link_text: "link_text", url: "url", hint_text: "hint_text")
    end

    def error_with_link_and_hint_text
      render CollapsedSection::View.new(title: "title", link_text: "link_text", url: "url", hint_text: "hint_text", has_errors: true)
    end
  end
end
