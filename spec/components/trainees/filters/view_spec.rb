# frozen_string_literal: true

require "rails_helper"

RSpec.describe Trainees::Filters::View do
  let(:selected_text) { "Selected filters" }
  let(:permitted_filters) { filters.permit(:subject, record_type: []) }
  let(:result) { render_inline described_class.new(permitted_filters) }

  context "when no filters are applied" do
    let(:filters) { ActionController::Parameters.new({}) }

    it "all of the checkboxes are unchecked" do
      expect(result.css("#record_type-assessment_only").attr("checked")).to eq(nil)
      expect(result.css("#record_type-provider_led").attr("checked")).to eq(nil)
    end

    it "does not show a 'Selected filters' dialogue" do
      expect(result.text).not_to include(selected_text)
    end
  end

  context "when checkboxes have been pre-selected" do
    let(:filters) do
      ActionController::Parameters.new({ record_type: %w[assessment_only] })
    end

    it "marks the correct ones as selected" do
      expect(result.css("#record_type-assessment_only").attr("checked").value).to eq("checked")
      expect(result.css("#record_type-provider_led").attr("checked")).to eq(nil)
    end

    it "shows a 'Selected filters' dialogue" do
      expect(result.text).to include(selected_text)
    end
  end

  context "when a subject has been pre-selected" do
    let(:filters) do
      ActionController::Parameters.new({ subject: "Business studies" })
    end

    it "retains the input" do
      selected_value = result.css('#subject option[@selected="selected"]').attr("value").value
      expect(selected_value).to eq("Business studies")
    end

    it "shows a 'Selected filters' dialogue" do
      expect(result.text).to include(selected_text)
    end
  end

  context "when 'All subjects' has been selected" do
    let(:filters) do
      ActionController::Parameters.new({ subject: "All subjects" })
    end

    it "does not show a 'Selected filters' dialogue" do
      expect(result.text).to_not include(selected_text)
    end
  end
end
