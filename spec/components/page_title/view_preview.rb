require "govuk/components"

class PageTitle::ViewPreview < ViewComponent::Preview
  def default_heading
    render_component(PageTitle::View.new(title: "trainees.new"))
  end

  def heading_with_error
    render_component(PageTitle::View.new(title: "trainees.new", errors: "Error"))
  end
end
