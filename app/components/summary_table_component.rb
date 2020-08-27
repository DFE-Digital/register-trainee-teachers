class SummaryTableComponent < ViewComponent::Base
  attr_reader :content_hash

  def initialize(content_hash:)
    @content_hash = content_hash
  end
end
