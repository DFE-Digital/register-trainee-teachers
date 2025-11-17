# frozen_string_literal: true

require "rails_helper"

module SchoolDetails
  describe View do
    shared_examples("school row") do |field_name|
      it "renders the school type" do
        expect(rendered_content).to have_text(field_name.humanize)
      end

      it "renders the school name" do
        expect(rendered_content).to have_text(school.name)
      end

      it "renders the school location" do
        expected_location_format = "URN #{urn}, #{school.town}, #{school.postcode}"
        expect(rendered_content).to have_text(expected_location_format)
      end

      it "renders the school change link" do
        expect(rendered_content).to have_link(t("change"))
      end
    end

    context "with lead partner" do
      let(:trainee) { create(:trainee, :school_direct_salaried, :with_lead_partner) }
      let(:school) { trainee.lead_partner.school }
      let(:urn) { trainee.lead_partner.urn }

      before do
        render_inline(View.new(trainee: trainee, editable: true))
      end

      it_behaves_like("school row", "training partner")
    end

    context "with employing school" do
      let(:trainee) { create(:trainee, :school_direct_salaried, :with_employing_school) }
      let(:school) { trainee.employing_school }
      let(:urn) { trainee.employing_school.urn }

      before do
        render_inline(View.new(trainee: trainee, editable: true))
      end

      it_behaves_like("school row", "employing school")
    end

    context "when urn not provided from hesa import" do
      let(:trainee) { create(:trainee, :imported_from_hesa) }

      before do
        render_inline(View.new(trainee: trainee, editable: true))
      end

      it "renders the not imported from hesa message" do
        expect(rendered_content).to have_text(t("components.confirmation.not_provided_from_hesa_update"))
      end
    end
  end
end
