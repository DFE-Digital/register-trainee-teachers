# frozen_string_literal: true

require "rails_helper"

RSpec.describe SelectPlacementSchoolForm, type: :model do
  include ActionView::Helpers::SanitizeHelper

  subject(:form) { described_class.new(trainee: trainee, query: "Reading") }

  let(:trainee) { double("Trainee", slug: "trainee0001") }

  describe "validations" do
    it { is_expected.to validate_presence_of(:school_id) }
  end

  describe "#search_results" do
    it "calls SchoolSearch with the correct parameters" do
      form = described_class.new(trainee: trainee, query: "Birmingham")
      expect(SchoolSearch).to receive(:call).with(query: "Birmingham")
      form.search_results
    end
  end

  describe "#form_path" do
    context "when updating an existing placement" do
      it "returns the correct path" do
        form = described_class.new(
          trainee: trainee,
          query: "Oxford",
          placement_slug: "placement0001",
        )

        expect(form.form_path).to eq(
          Rails.application.routes.url_helpers.trainee_placement_school_search_path(
            trainee_id: "trainee0001",
            id: "placement0001",
          ),
        )
      end
    end

    context "when creating a new placement" do
      it "returns the correct path" do
        form = described_class.new(
          trainee: trainee,
          query: "Oxford",
          placement_slug: nil,
        )

        expect(form.form_path).to eq(
          Rails.application.routes.url_helpers.trainee_placement_school_search_index_path(
            trainee_id: "trainee0001",
          ),
        )
      end
    end
  end

  describe "#form_method" do
    context "when updating an existing placement" do
      it "returns :patch" do
        form = described_class.new(
          trainee: trainee,
          query: "Oxford",
          placement_slug: "placement0001",
        )

        expect(form.form_method).to eq(:patch)
      end
    end

    context "when creating a new placement" do
      it "returns :post" do
        form = described_class.new(
          trainee: trainee,
          query: "Oxford",
          placement_slug: nil,
        )
        expect(form.form_method).to eq(:post)
      end
    end
  end

  describe "#title" do
    let(:results) { double("SchoolSearchResults", schools: [], total_count: total_count) }

    before do
      allow(SchoolSearch).to receive(:call).and_return(results)
    end

    context "when no results are found" do
      let(:total_count) { 0 }

      it "returns the correct title" do
        form = described_class.new(trainee: trainee, query: "Oxford")
        expect(form.title).to eq("No results found for ‘Oxford’")
      end
    end

    context "when one result is found" do
      let(:total_count) { 1 }

      it "returns the correct title" do
        form = described_class.new(trainee: trainee, query: "Reading")
        expect(form.title).to eq("1 result found")
      end
    end

    context "when multiple results are found" do
      let(:total_count) { 6 }

      it "returns the correct title" do
        form = described_class.new(trainee: trainee, query: "Newbury")
        expect(form.title).to eq("6 results found")
      end
    end
  end

  describe "#hint_text" do
    let(:results) { double("SchoolSearchResults", schools: [], total_count: total_count) }

    before do
      allow(SchoolSearch).to receive(:call).and_return(results)
    end

    context "when no results are found" do
      let(:total_count) { 0 }

      it "returns the correct hint text" do
        form = described_class.new(trainee: trainee, query: "Oxford")
        expect(strip_tags(form.hint_text)).to eq("Change your search")
      end
    end

    context "when multiple results are found less than the page limit" do
      let(:total_count) { 6 }

      it "returns the correct hint text" do
        form = described_class.new(trainee: trainee, query: "Newbury")
        expect(strip_tags(form.hint_text)).to eq(
          "Change your search if the school you’re looking for is not listed.",
        )
      end
    end

    context "when multiple results are found more than the page limit" do
      let(:total_count) { SchoolSearch::DEFAULT_LIMIT + 1 }

      it "returns the correct hint text" do
        form = described_class.new(trainee: trainee, query: "Newbury")
        expect(strip_tags(form.hint_text)).to eq(
          "Showing the first #{SchoolSearch::DEFAULT_LIMIT} results. Try narrowing down your search if the school you’re looking for is not listed.",
        )
      end
    end
  end
end
