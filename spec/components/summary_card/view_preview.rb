# frozen_string_literal: true

require "govuk/components"
class SummaryCard::ViewPreview < ViewComponent::Preview
  def with_no_action_links
    render(SummaryCard::View.new(trainee: Trainee.new(id: 1), title: "Personal Details", rows: [
      { key: "First names", value: "Mike" },
      { key: "Middle names", value: "Larson" },
      { key: "Last name", value: "Doyle" },
    ]))
  end

  def with_action_links
    render(SummaryCard::View.new(trainee: Trainee.new(id: 1), title: "Personal Details", rows: [
      {
        key: "First names",
        value: "Mike",
        action_href: "#mike",
        action_text: "Change",
        action_visually_hidden_text: "first names",
      },
      {
        key: "Middle names",
        value: "Larson",
      },
      {
        key: "Last name",
        value: "Doyle",
        action_href: "http://example.com",
        action_text: "Delete",
        action_visually_hidden_text: "last name",
      },
    ]))
  end
end
