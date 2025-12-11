# frozen_string_literal: true

require "rails_helper"

module Schools
  describe View do
    include Rails.application.routes.url_helpers

    let(:training_partner) { create(:training_partner, :school) }
    let(:employing_school) { create(:school, open_date: Time.zone.today) }

    before do
      render_inline(View.new(data_model: trainee, editable: true))
    end

    context "when trainee is on a school direct salaried route" do
      let(:trainee) { create(:trainee, lead_partner: lead_partner, employing_school: employing_school, training_route: 4) }

      describe "lead school" do
        it "renders" do
          expect(rendered_content).to have_text(trainee.lead_partner.name)
          expect(rendered_content).to have_text(trainee.lead_partner.urn)
          expect(rendered_content).to have_text(trainee.lead_partner.school.town)
          expect(rendered_content).to have_text(trainee.lead_partner.school.postcode)
        end

        it "has correct change links" do
          expect(rendered_content).to have_link(href: "/trainees/#{trainee.slug}/training-partners/details/edit")
        end
      end

      describe "employing school" do
        it "renders" do
          expect(rendered_content).to have_text(trainee.employing_school.name)
          expect(rendered_content).to have_text(trainee.employing_school.urn)
          expect(rendered_content).to have_text(trainee.employing_school.town)
          expect(rendered_content).to have_text(trainee.employing_school.postcode)
        end

        it "has correct change links" do
          expect(rendered_content).to have_link(href: "/trainees/#{trainee.slug}/employing-schools/details/edit")
        end
      end
    end

    context "when trainee is on a school direct tuition fee route" do
      let(:trainee) { create(:trainee, lead_partner: lead_partner, employing_school: employing_school, training_route: 3) }

      describe "lead school" do
        it "renders" do
          expect(rendered_content).to have_text(trainee.lead_partner.name)
          expect(rendered_content).to have_text(trainee.lead_partner.urn)
          expect(rendered_content).to have_text(trainee.lead_partner.school.town)
          expect(rendered_content).to have_text(trainee.lead_partner.school.postcode)
        end

        it "has correct change links" do
          expect(rendered_content).to have_link(href: "/trainees/#{trainee.slug}/training-partners/details/edit")
        end
      end

      describe "employing school" do
        it "does not render" do
          expect(rendered_content).not_to have_text(trainee.employing_school.name)
          expect(rendered_content).not_to have_text(trainee.employing_school.urn)
          expect(rendered_content).not_to have_text(trainee.employing_school.town)
          expect(rendered_content).not_to have_text(trainee.employing_school.postcode)
        end
      end
    end
  end
end
