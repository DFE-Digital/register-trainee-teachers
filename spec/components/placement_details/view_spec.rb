# frozen_string_literal: true

require "rails_helper"

module PlacementDetails
  describe View do
    let(:data_model) { trainee }
    let(:trainee) { create(:trainee, placements:) }
    let(:placements) { [] }
    let(:editable) { false }

    subject do
      render_inline(described_class.new(data_model:, editable:))
    end

    it "does not have editable links" do
      expect(subject).not_to have_link("Manage placements", href: "/trainees/#{trainee.slug}/placements/confirm")
      expect(subject).not_to have_link(href: "/trainees/#{trainee.slug}/placements/new")
    end

    it "shows the placement details" do
      expect(subject).to have_css(".govuk-summary-list__row", count: 2)

      expect(subject).to have_css(".govuk-summary-list__row .govuk-summary-list__key", text: "First placement")
      expect(subject).to have_css(".govuk-summary-list__row .govuk-summary-list__value", text: "First placement is missing")

      expect(subject).to have_css(".govuk-summary-list__row .govuk-summary-list__key", text: "Second placement")
      expect(subject).to have_css(".govuk-summary-list__row .govuk-summary-list__value", text: "Second placement is missing")
    end

    context "editable is true" do
      let(:editable) { true }

      it "has editable links" do
        expect(subject).to have_link("Manage placements", href: "/trainees/#{trainee.slug}/placements/confirm")
        expect(subject).to have_link("Enter first placement", href: "/trainees/#{trainee.slug}/placements/new")
      end

      context "when there is 1 placements" do
        let(:placements) { create_list(:placement, 1) }

        it "shows the placement details" do
          expect(subject).to have_css(".govuk-summary-list__row", count: 2)

          expect(subject).to have_css(".govuk-summary-list__row .govuk-summary-list__key", text: "First placement")
          expect(subject).to have_css(".govuk-summary-list__row .govuk-summary-list__value", text: placements.first.name)
          expect(subject).to have_css(".govuk-summary-list__row .govuk-summary-list__value", text: placements.first.full_address)

          expect(subject).to have_css(".govuk-summary-list__row .govuk-summary-list__key", text: "Second placement")
          expect(subject).to have_css(".govuk-summary-list__row .govuk-summary-list__value", text: "Second placement is missing")
        end

        it "has editable links" do
          expect(subject).to have_link("Manage placements", href: "/trainees/#{trainee.slug}/placements/confirm")
          expect(subject).to have_link("Enter second placement", href: "/trainees/#{trainee.slug}/placements/new")
        end
      end

      context "when there is 2 placements" do
        let(:placements) { create_list(:placement, 2) }

        it "shows the placement details" do
          expect(subject).to have_css(".govuk-summary-list__row", count: 2)

          expect(subject).to have_css(".govuk-summary-list__row .govuk-summary-list__key", text: "First placement")
          expect(subject).to have_css(".govuk-summary-list__row .govuk-summary-list__key", text: "Second placement")

          trainee.placements.each do |placement|
            expect(subject).to have_css(".govuk-summary-list__row .govuk-summary-list__value", text: placement.name)
            expect(subject).to have_css(".govuk-summary-list__row .govuk-summary-list__value", text: placement.full_address)
          end
        end

        it "has editable links" do
          expect(subject).to have_link("Manage placements", href: "/trainees/#{trainee.slug}/placements/confirm")
        end
      end

      context "when there is 5 placements" do
        let(:placements) { create_list(:placement, 5) }

        it "shows the placement details" do
          expect(subject).to have_css(".govuk-summary-list__row", count: 5)

          expect(subject).to have_css(".govuk-summary-list__row .govuk-summary-list__key", text: "First placement")
          expect(subject).to have_css(".govuk-summary-list__row .govuk-summary-list__key", text: "Second placement")
          expect(subject).to have_css(".govuk-summary-list__row .govuk-summary-list__key", text: "Third placement")
          expect(subject).to have_css(".govuk-summary-list__row .govuk-summary-list__key", text: "Fourth placement")
          expect(subject).to have_css(".govuk-summary-list__row .govuk-summary-list__key", text: "Fifth placement")

          trainee.placements.each do |placement|
            expect(subject).to have_css(".govuk-summary-list__row .govuk-summary-list__value", text: placement.name)
            expect(subject).to have_css(".govuk-summary-list__row .govuk-summary-list__value", text: placement.full_address)
          end
        end

        it "has editable links" do
          expect(subject).to have_link("Manage placements", href: "/trainees/#{trainee.slug}/placements/confirm")
        end
      end
    end
  end
end
