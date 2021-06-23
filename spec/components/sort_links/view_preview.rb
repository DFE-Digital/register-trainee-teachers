# frozen_string_literal: true

require "govuk/components"

module SortLinks
  class ViewPreview < ViewComponent::Preview
    def default_view
      render View.new
    end
  end
end
