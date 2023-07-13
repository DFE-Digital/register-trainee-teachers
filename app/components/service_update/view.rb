# frozen_string_literal: true

class ServiceUpdate::View < ComponentBase
  attr_reader :service_update

  delegate :title, :content, :date, to: :service_update

  TITLE_TAGS = %w[h1 h2 h3 h4 h5 h6].freeze
  TITLE_CLASS = "govuk-heading-m govuk-!-margin-bottom-2"

  def initialize(service_update:, title_tag: "h2")
    @service_update = service_update
    @title_tag = title_tag
  end

  def render?
    service_update
  end

  def title_element
    return tag.public_send(title_tag, title, class: TITLE_CLASS) if TITLE_TAGS.include?(title_tag)

    tag.h2(title, class: TITLE_CLASS)
  end

  def date_pretty
    date.to_date.strftime("%e %B %Y")
  end

  def content_html
    custom_render = Redcarpet::Render::HTML.new(link_attributes: { class: "govuk-link" })
    Redcarpet::Markdown.new(custom_render).render(content).html_safe
  end

private

  attr_reader :title_tag
end
