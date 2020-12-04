# frozen_string_literal: true

module ApplicationHelper
  def to_options(array)
    result = array.map do |name|
      OpenStruct.new(name: name)
    end
    result.unshift(OpenStruct.new(name: nil))
    result
  end

  def govuk_button_link_to(body, url, html_options = {})
    original_html_option_class = html_options[:class]
    html_options[:class] = css_classes("govuk-button", original_html_option_class)
    html_options[:role] = "button" unless html_options.key?(:role)
    html_options[:draggable] = false unless html_options.key?(:draggable)

    return link_to(url, html_options) { yield } if block_given?

    link_to(body, url, html_options)
  end

private

  def css_classes(css_class, current_class)
    if current_class
      "#{css_class} #{current_class}"
    else
      css_class
    end
  end
end
