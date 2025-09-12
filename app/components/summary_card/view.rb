# frozen_string_literal: true

class SummaryCard::View < ApplicationComponent
  renders_one :header_actions

  def initialize(title:, heading_level: 2, rows:, id_suffix: nil, editable: true, id: nil)
    @title = title
    @heading_level = heading_level
    @rows = rows
    @editable = editable
    @id_suffix = id_suffix
    @id = id
  end

  def summary_rows
    @rows
  end

private

  attr_accessor :title, :heading_level, :id_suffix, :editable, :id

  def row_title(key)
    return key.parameterize if id_suffix.nil?

    "#{key.parameterize}-#{id_suffix}"
  end
end
