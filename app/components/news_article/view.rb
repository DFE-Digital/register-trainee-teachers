# frozen_string_literal: true

class NewsArticle::View < ViewComponent::Base
  attr_reader :news_article

  delegate :title, :content, :date, to: :news_article

  def initialize(news_article:)
    @news_article = news_article
  end

  def render?
    news_article
  end

  def title_element
    tag.h1(title, class: "govuk-heading-l govuk-!-margin-bottom-2")
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
