# frozen_string_literal: true

require "govuk/components"

class PageTitle::ViewPreview < ViewComponent::Preview
  def default_heading
    render(PageTitle::View.new(title: "trainees.new"))
  end

  def heading_with_error
    render(PageTitle::View.new(title: "trainees.new", has_errors: true))
  end
end
