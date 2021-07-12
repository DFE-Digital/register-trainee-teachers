# frozen_string_literal: true

require "rails_helper"

module Schools
  describe View do
    include Rails.application.routes.url_helpers

    let(:school1) { create(:school, open_date: Time.zone.today) }
    let(:school2) { create(:school, open_date: Time.zone.today) }

    before do
      render_inline(View.new(data_model: trainee))
    end

    context "when trainee is on a school direct salaried route" do
      let(:trainee) { create(:trainee, lead_school: school1, employing_school: school2, training_route: 4) }

      describe "lead school" do
        it "renders" do
          expect(rendered_component).to have_text(trainee.lead_school.name)
          expect(rendered_component).to have_text(trainee.lead_school.urn)
          expect(rendered_component).to have_text(trainee.lead_school.town)
          expect(rendered_component).to have_text(trainee.lead_school.postcode)
        end

        it "has correct change links" do
          expect(rendered_component).to have_link(href: "/trainees/#{trainee.slug}/lead-schools/edit")
        end
      end

      describe "employing school" do
        it "renders" do
          expect(rendered_component).to have_text(trainee.employing_school.name)
          expect(rendered_component).to have_text(trainee.employing_school.urn)
          expect(rendered_component).to have_text(trainee.employing_school.town)
          expect(rendered_component).to have_text(trainee.employing_school.postcode)
        end

        it "has correct change links" do
          expect(rendered_component).to have_link(href: "/trainees/#{trainee.slug}/employing-schools/edit")
        end
      end
    end

    context "when trainee is on a school direct tuition fee route" do
      let(:trainee) { create(:trainee, lead_school: school1, employing_school: school2, training_route: 3) }

      describe "lead school" do
        it "renders" do
          expect(rendered_component).to have_text(trainee.lead_school.name)
          expect(rendered_component).to have_text(trainee.lead_school.urn)
          expect(rendered_component).to have_text(trainee.lead_school.town)
          expect(rendered_component).to have_text(trainee.lead_school.postcode)
        end

        it "has correct change links" do
          expect(rendered_component).to have_link(href: "/trainees/#{trainee.slug}/lead-schools/edit")
        end
      end

      describe "employing school" do
        it "does not render" do
          expect(rendered_component).not_to have_text(trainee.employing_school.name)
          expect(rendered_component).not_to have_text(trainee.employing_school.urn)
          expect(rendered_component).not_to have_text(trainee.employing_school.town)
          expect(rendered_component).not_to have_text(trainee.employing_school.postcode)
        end
      end
    end
  end
end
