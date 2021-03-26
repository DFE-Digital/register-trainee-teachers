# frozen_string_literal: true

module ButtonLinkTo
  class View < GovukComponent::Base
    attr_reader :body, :url, :class_option, :id

    def initialize(body:, url:, class_option: nil, id: nil)
      @body = body
      @url = url
      @class_option = class_option
      @id = id
    end

    def call
      html_options = {
        role: "button",
        data: { module: "govuk-button" },
        draggable: false,
        id: id,
      }.merge({ class: class_option })

      html_options[:class] = prepend_css_class("govuk-button", html_options[:class])

      return link_to(body, url, html_options) if id.present?

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
