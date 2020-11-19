# frozen_string_literal: true

class SummaryCard::View < ViewComponent::Base
  attr_accessor :title, :heading_level, :rows
  def initialize(title:, heading_level: 2, rows:)
    @title = title
    @heading_level = heading_level
    @rows = rows
  end
end
