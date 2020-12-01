# frozen_string_literal: true

class SummaryCard::View < ViewComponent::Base
  include ViewComponent::Slotable
  with_content_areas :header_actions

  attr_accessor :title, :heading_level, :rows

  def initialize(title:, heading_level: 2, rows:)
    @title = title
    @heading_level = heading_level
    @rows = rows
  end
end
