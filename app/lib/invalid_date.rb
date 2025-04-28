# frozen_string_literal: true

InvalidDate = Struct.new(:day, :month, :year, keyword_init: true) do
  def blank?
    members.all? { |date_field| public_send(date_field).blank? }
  end

  def future?
    false
  end

  def to_s
    values.join("/")
  end
end
