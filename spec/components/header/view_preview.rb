# frozen_string_literal: true

module Header
  class ViewPreview < ViewComponent::Preview
    def with_govuk_logo
      render(Header::View.new)
    end
  end
end
