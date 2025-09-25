# frozen_string_literal: true

module GovukButtonLinkTo
  class View < ApplicationComponent
    attr_reader :body, :url, :class_option, :html

    def initialize(body:, url:, class_option: "", **html)
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

      html_options[:class] += " govuk-button"
      html_options[:class].strip!

      link_to(body, url, html_options)
    end
  end
end
