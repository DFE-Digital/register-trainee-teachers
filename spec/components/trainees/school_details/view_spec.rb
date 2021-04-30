# frozen_string_literal: true

require "rails_helper"

module Trainees
  module SchoolDetails
    describe View do
      alias_method :component, :page

      shared_examples("school row") do |field_name|
        subject do
          component.find(".govuk-summary-list__row.#{field_name.parameterize}")
        end

        it "renders the school type" do
          expect(subject).to have_text(field_name.humanize)
        end

        it "renders the school name" do
          expect(subject).to have_text(school.name)
        end

        it "renders the school location" do
          expected_location_format = "URN #{school.urn}, #{school.town}, #{school.postcode}"
          expect(subject).to have_text(expected_location_format)
        end

        it "renders the school change link" do
          expect(subject).to have_link(t("change"))
        end
      end

      context "with lead school" do
        let(:trainee) { create(:trainee, :school_direct_salaried, :with_lead_school) }
        let(:school) { trainee.lead_school }

        before do
          render_inline(View.new(trainee))
        end

        it_behaves_like("school row", "lead school")
      end

      context "with employing school" do
        let(:trainee) { create(:trainee, :school_direct_salaried, :with_employing_school) }
        let(:school) { trainee.employing_school }

        before do
          render_inline(View.new(trainee))
        end

        it_behaves_like("school row", "employing school")
      end
    end
  end
end
