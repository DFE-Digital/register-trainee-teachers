# frozen_string_literal: true

require "rails_helper"

RSpec.describe Filters::View do
  let(:trainees_path) { "/trainees" }
  let(:selected_text) { "Selected filters" }
  let(:result) { render_inline(described_class.new(filters: filters, filter_options: [])) }

  before do
    # When link_to() is called with a nil path, it normally renders a href using the current URL path without
    # the query params. However, link_to() blows up in this spec unless we mock the route so it behaves as if
    # it's a real app rendering the template.
    allow_any_instance_of(ActionDispatch::Journey::Route).to receive(:dispatcher?).and_return(true)

    # Override the route /sidekiq, which seems to show up as the default route
    allow_any_instance_of(ActionDispatch::Journey::Formatter::RouteWithParams).to receive(:path).and_return(trainees_path)
  end

  context "when no filters are applied" do
    let(:filters) { nil }

    it "all of the checkboxes are unchecked" do
      expect(result.css("#state-draft").attr("checked")).to eq(nil)
    end

    it "does not show a 'Selected filters' dialogue" do
      expect(result.text).not_to include(selected_text)
    end
  end

  context "when checkboxes have been pre-selected" do
    let(:filters) { { state: %w[draft] }.with_indifferent_access }

    it "shows a 'Selected filters' dialogue" do
      expect(result.text).to include(selected_text)
    end
  end

  context "when a subject has been pre-selected" do
    let(:filters) { { subject: "Business studies" }.with_indifferent_access }

    it "shows a 'Selected filters' dialogue" do
      expect(result.text).to include(selected_text)
    end
  end

  context "a single checkbox filter" do
    let(:filters) { { state: %w[draft] }.with_indifferent_access }

    it "has no query params in URL" do
      expect(result.css("a.moj-filter__tag").attr("href").value).to eq(trainees_path)
    end
  end

  context "a subject filter" do
    let(:filters) { { subject: "English" }.with_indifferent_access }

    it "has no query params in URL" do
      expect(result.css("a.moj-filter__tag").attr("href").value).to eq(trainees_path)
    end
  end
end
