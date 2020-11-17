# frozen_string_literal: true

require "govuk/components"
class SummaryCard::ViewPreview < ViewComponent::Preview
  def with_no_action_links
    render_component(SummaryCard::View.new(title: "Personal Details", rows: [
      { key: "First names", value: "Mike" },
      { key: "Middle names", value: "Larson" },
      { key: "Last name", value: "Doyle" },
    ]))
  end

  def with_action_links
    render_component(SummaryCard::View.new(title: "Personal Details", rows: [
      { key: "First names", value: "Mike", action: '<a href="#mike" class="govuk-link">Change</a>'.html_safe },
      { key: "Middle names", value: "Larson" },
      { key: "Last name", value: "Doyle", action: '<a href="http://example.com" class="govuk-link">Delete</a>'.html_safe },
    ]))
  end
end
