# frozen_string_literal: true

class TimelineEvent
  attr_reader :title, :date, :username, :items

  def initialize(title:, date:, username:, items:)
    @title = title
    @date = date
    @username = username
    @items = items
  end
end
