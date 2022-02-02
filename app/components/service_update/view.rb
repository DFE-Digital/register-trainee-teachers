# frozen_string_literal: true

class ServiceUpdate::View < GovukComponent::Base
  attr_reader :service_update

  delegate :title, :content, :date,
           to: :service_update

  def initialize(service_update:)
    @service_update = service_update
  end

  def render?
    service_update
  end

  def date_pretty
    date.to_date.strftime("%e %B %Y")
  end

  def content_html
    custom_render = Redcarpet::Render::HTML.new(link_attributes: { class: "govuk-link" })
    Redcarpet::Markdown.new(custom_render).render(content).html_safe
  end
end
