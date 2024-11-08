# frozen_string_literal: true

class String
  def to_title
    humanize.gsub(/\b('?[a-z])/) { ::Regexp.last_match(1).capitalize }
  end
end
