# frozen_string_literal: true

module ApplicationHelper
  def to_options(array, first_value: nil)
    result = array.map do |name|
      OpenStruct.new(name: name)
    end
    result.unshift(OpenStruct.new(name: first_value))
    result
  end

  def govuk_button_link_to(body, url, html_options = {})
    html_options = {
      role: "button",
      data: { module: "govuk-button" },
      draggable: false,
    }.merge(html_options)

    html_options[:class] = prepend_css_class("govuk-button", html_options[:class])

    return link_to(url, html_options) { yield } if block_given?

    link_to(body, url, html_options)
  end

  def form_with(*args, &block)
    options = args.extract_options!
    defaults = { html: { novalidate: true } }
    super(*args << defaults.deep_merge(options), &block)
  end

  def header_items(current_user)
    return unless current_user

    items = [{ name: t("header.items.sign_out"), url: sign_out_path }]
    items.unshift({ name: t("header.items.system_admin"), url: providers_path }) if current_user.system_admin?
    items
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
