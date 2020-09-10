class SummaryCard::ViewPreview < ViewComponent::Preview
  def default_state
    render_component(SummaryCard::View.new(rows: {
      "First names": "Mike",
      "Middle names": "Larson",
      "Last name": "Doyle",
    })) do
      "Hello"
      end
  end
end
