# frozen_string_literal: true

require "rails_helper"

module SelectPlacementSchool
  describe View do
    include ActionView::Helpers::TextHelper

    let(:trainee) { create(:trainee) }
    let(:slug) { nil }
    let(:query) { "Oxford" }
    let(:model) { SelectPlacementSchoolForm.new(trainee:, query:) }

    let(:select_placement_school_component) do
      described_class.new(model:, slug:, query:, trainee:)
    end

    describe "#search_results" do
      let(:query) { "Birmingham" }

      it "calls SchoolSearch with the correct parameters" do
        expect(SchoolSearch).to receive(:call).with(query: "Birmingham")
        select_placement_school_component.search_results
      end
    end

    describe "#form_path" do
      before do
        render_inline(select_placement_school_component)
      end

      context "when updating an existing placement" do
        let(:slug) { "placement0001" }

        it "returns the correct path" do
          expect(rendered_content).to include(
            Rails.application.routes.url_helpers.trainee_placement_school_search_path(
              trainee_id: trainee.slug,
              id: "placement0001",
            ),
          )
        end
      end

      context "when creating a new placement" do
        it "returns the correct path" do
          expect(rendered_content).to include(
            Rails.application.routes.url_helpers.trainee_placement_school_search_index_path(
              trainee_id: trainee.slug,
            ),
          )
        end
      end
    end

    describe "#form_method" do
      context "when updating an existing placement" do
        let(:slug) { "placement0001" }

        it "returns :patch" do
          expect(select_placement_school_component.form_method).to eq(:patch)
        end
      end

      context "when creating a new placement" do
        it "returns :post" do
          expect(select_placement_school_component.form_method).to eq(:post)
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
          expect(select_placement_school_component.title).to eq("No results found for ‘Oxford’")
        end
      end

      context "when one result is found" do
        let(:total_count) { 1 }

        it "returns the correct title" do
          expect(select_placement_school_component.title).to eq("1 result found")
        end
      end

      context "when multiple results are found" do
        let(:total_count) { 6 }

        it "returns the correct title" do
          expect(select_placement_school_component.title).to eq("6 results found")
        end
      end
    end

    describe "#hint_text" do
      let(:results) { double("SchoolSearchResults", schools: [], total_count: total_count) }

      before do
        allow(SchoolSearch).to receive(:call).and_return(results)
        render_inline(select_placement_school_component)
      end

      context "when no results are found" do
        let(:total_count) { 0 }

        it "returns the correct hint text" do
          expect(rendered_content).to include("Change your search")
        end
      end

      context "when multiple results are found less than the page limit" do
        let(:total_count) { 6 }

        it "returns the correct hint text" do
          expect(strip_tags(rendered_content)).to include(
            "Change your search if the school you’re looking for is not listed.",
          )
        end
      end

      context "when multiple results are found more than the page limit" do
        let(:total_count) { SchoolSearch::DEFAULT_LIMIT + 1 }

        it "returns the correct hint text" do
          expect(strip_tags(rendered_content)).to include(
            "Showing the first #{SchoolSearch::DEFAULT_LIMIT} results. Try narrowing down your search if the school you’re looking for is not listed.",
          )
        end
      end
    end
  end
end
