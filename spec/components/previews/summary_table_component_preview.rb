class SummaryTableComponentPreview < ViewComponent::Preview
  def default_state
    render(SummaryTableComponent.new(content_hash: {
      "First names": "Mike",
      "Middle names": "Larson",
      "Last name": "Doyle",
    }))
  end
end
