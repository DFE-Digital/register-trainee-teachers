# frozen_string_literal: true

class StartPageBanner::ViewPreview < ViewComponent::Preview
  def default_state
    render(StartPageBanner::View.new)
  end
end
