# frozen_string_literal: true

class SummaryCard::View < ViewComponent::Base
  renders_one :header_actions

  def initialize(title:, heading_level: 2, rows:, id_suffix: nil)
    @title = title
    @heading_level = heading_level
    @rows = rows
    @id_suffix = id_suffix
  end

  def summary_rows
    @rows
  end

private

  attr_accessor :title, :heading_level, :id_suffix

  def row_title(key)
    return key.parameterize if id_suffix.nil?

    "#{key.parameterize}-#{id_suffix}"
  end
end
