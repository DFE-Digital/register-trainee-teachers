# frozen_string_literal: true

class BlueInsetTextWithLink::View < ViewComponent::Base
  attr_accessor :title, :url, :link_text

  def initialize(title:, link_text:, url:)
    @url = url
    @link_text = link_text
    @title = title
  end

  def text
    tag.p(class: "app-inset-text__title") { title } + govuk_link_to(link_text, url)
  end
end
