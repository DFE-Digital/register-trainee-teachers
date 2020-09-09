class SummaryTable::ComponentPreview < ViewComponent::Preview
  def default_state
    render(SummaryTable::Component.new(content_hash: {
      "First names": "Mike",
      "Middle names": "Larson",
      "Last name": "Doyle",
    }))
  end
end
