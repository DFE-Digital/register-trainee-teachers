class SummaryCard::ViewPreview < ViewComponent::Preview
  def default_state
    render_component(SummaryCard::View.new(title: "Personal Details", rows: {
      "First names": "Mike",
      "Middle names": "Larson",
      "Last name": "Doyle",
    }))
  end
end
