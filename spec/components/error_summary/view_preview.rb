# frozen_string_literal: true

module ErrorSummary
  class ViewPreview < ViewComponent::Preview
    def default
      render(View.new(has_errors: true)) do
        "<li>This is an error item</li>".html_safe
      end
    end
  end
end
