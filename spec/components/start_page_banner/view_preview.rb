class StartPageBanner::ViewPreview < ViewComponent::Preview
  def default_state
    render_component(StartPageBanner::View.new)
  end
end
