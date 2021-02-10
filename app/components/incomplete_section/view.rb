# frozen_string_literal: true

class IncompleteSection::View < ViewComponent::Base
  attr_accessor :title, :url, :link_text, :error

  def initialize(title:, link_text:, url:, error: false)
    @url = url
    @link_text = link_text
    @title = title
    @error = error
  end
end
