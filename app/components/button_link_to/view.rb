# frozen_string_literal: true

module ButtonLinkTo
  class View < GovukComponent::Base
    attr_reader :body, :url, :class_option, :html

    def initialize(body:, url:, class_option: nil, **html)
      @body = body
      @url = url
      @class_option = class_option
      @html = html
    end

    def call
      html_options = {
        role: "button",
        data: { module: "govuk-button" },
        draggable: false,
      }.merge({ class: class_option }, html)

      html_options[:class] = prepend_css_class("govuk-button", html_options[:class])

      link_to(body, url, html_options)
    end

  private

    def prepend_css_class(css_class, current_class)
      if current_class
        "#{css_class} #{current_class}"
      else
        css_class
      end
    end
  end
end
