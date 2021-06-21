# frozen_string_literal: true

require "govuk/components"

class PageTitle::ViewPreview < ViewComponent::Preview
  def key_heading
    render(PageTitle::View.new(i18n_key: "trainees.new"))
  end

  def key_heading_with_error
    render(PageTitle::View.new(i18n_key: "trainees.new", has_errors: true))
  end

  def text_heading
    render(PageTitle::View.new(text: "Test heading"))
  end

  def text_heading_with_error
    render(PageTitle::View.new(text: "Test heading", has_errors: true))
  end
end
