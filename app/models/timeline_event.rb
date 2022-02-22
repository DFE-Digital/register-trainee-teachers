# frozen_string_literal: true

class TimelineEvent
  attr_reader :title, :date, :username, :items

  def initialize(title:, date:, username: nil, items: nil)
    @title = title
    @date = date
    @username = username
    @items = items
  end
end
