# frozen_string_literal: true

require "rails_helper"

module Placements
  describe View do
    let(:placements) { [] }
    let(:trainee) { create(:trainee, placements:) }
    let(:data_model) { PlacementsForm.new(trainee) }

    before do
      render_inline(View.new(data_model:))
    end

    it "have guidance link" do
      expect(rendered_component).to have_link("Read DfE guidance about school placements", href: "https://www.gov.uk/government/publications/initial-teacher-training-criteria/initial-teacher-training-itt-criteria-and-supporting-advice#c23-training-in-schools")
    end

    it "have inset text" do
      expect(rendered_component).to have_text("You need to add the details of at least 2 schools before you can recommend this trainee for QTS. These can be added at any time.")
    end

    it "shows not provided placement" do
      expect(rendered_component).to have_text("Placement details")
      expect(rendered_component).to have_text("Placements")
      expect(rendered_component).to have_text("Not provided yet")
      expect(rendered_component).to have_link("Add a placement", href: "/trainees/#{trainee.slug}/placements/new", class: "govuk-link")
    end

    context "with 2 placements" do
      let(:placements) { create_list(:placement, 2, :manual) }

      it "shows the placement" do
        placements.each do |placement|
          expect(rendered_component).to have_text("School or setting")
          expect(rendered_component).to have_text(placement.name)
          expect(rendered_component).to have_text(placement.full_address)
        end
      end

      it "does not shows not provided placement" do
        expect(rendered_component).not_to have_text("Placement details")
        expect(rendered_component).not_to have_text("Placements")
        expect(rendered_component).not_to have_text("Not provided yet")
        expect(rendered_component).not_to have_link("Add a placement", href: "/trainees/#{trainee.slug}/placements/new", class: "govuk-link")
      end

      it "does not have inset text" do
        expect(rendered_component).not_to have_text("You need to add the details of at least 2 schools before you can recommend this trainee for QTS. These can be added at any time.")
      end

      it "have guidance link" do
        expect(rendered_component).to have_link("Read DfE guidance about school placements", href: "https://www.gov.uk/government/publications/initial-teacher-training-criteria/initial-teacher-training-itt-criteria-and-supporting-advice#c23-training-in-schools")
      end

      it "have add a placement button" do
        expect(rendered_component).to have_link("Add a placement", href: "/trainees/#{trainee.slug}/placements/new", class: "govuk-button--secondary govuk-button")
      end
    end
  end
end
