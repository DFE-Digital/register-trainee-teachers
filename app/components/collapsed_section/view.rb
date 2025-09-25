# frozen_string_literal: true

class CollapsedSection::View < ApplicationComponent
  attr_accessor :title, :url, :link_text, :hint_text, :has_errors, :name

  def initialize(title:, link_text: nil, url: nil, hint_text: nil, has_errors: false, name: nil)
    @url = url
    @link_text = link_text
    @title = title
    @hint_text = hint_text
    @has_errors = has_errors
    @name = name
  end
end
