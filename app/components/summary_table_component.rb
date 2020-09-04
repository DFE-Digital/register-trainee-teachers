class SummaryTableComponent < ViewComponent::Base
  attr_reader :content_hash

  def initialize(content_hash:)
    @content_hash = content_hash
  end

  def formatted_attribute_id(key)
    key.to_s.downcase.gsub(/ /, "-")
  end
end
