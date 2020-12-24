# frozen_string_literal: true

class SummaryCard::View < ViewComponent::Base
  include ViewComponent::Slotable

  with_content_areas :header_actions

  attr_accessor :trainee, :title, :heading_level

  def initialize(trainee:, title:, heading_level: 2, rows:)
    @trainee = trainee
    @title = title
    @heading_level = heading_level
    @rows = rows
  end

  def rows
    @rows.map do |row|
      row.tap do |r|
        r.delete(:action) if prevent_action?
      end
    end
  end

private

  def prevent_action?
    trainee.recommended_for_qts? || trainee.qts_awarded? || trainee.withdrawn?
  end
end
