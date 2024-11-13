# frozen_string_literal: true

class String
  def titleize_with_hyphens
    humanize.gsub(/\b([a-z])/) { ::Regexp.last_match(1).capitalize }
  end
end
