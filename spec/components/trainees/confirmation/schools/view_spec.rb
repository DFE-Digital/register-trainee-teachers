# frozen_string_literal: true

require "rails_helper"

module Trainees
  module Confirmation
    module Schools
      describe View do
        include Rails.application.routes.url_helpers
        alias_method :component, :page

        let(:school1) { create(:school, open_date: Time.zone.today) }
        let(:school2) { create(:school, open_date: Time.zone.today) }

        before do
          render_inline(View.new(data_model: trainee))
        end

        context "when trainee is on a school direct salaried route" do
          let(:trainee) { create(:trainee, lead_school: school1, employing_school: school2, training_route: 4) }

          describe "lead school" do
            subject { component.find(".govuk-summary-list__row.lead-school .govuk-summary-list__value") }
            it "renders" do
              expect(subject).to have_text(trainee.lead_school.name)
              expect(subject).to have_text(trainee.lead_school.urn)
              expect(subject).to have_text(trainee.lead_school.town)
              expect(subject).to have_text(trainee.lead_school.postcode)
            end

            it "has correct change links" do
              expect(component).to have_link(href: "/trainees/#{trainee.slug}/lead-schools/edit")
            end
          end

          describe "employing school" do
            subject { component.find(".govuk-summary-list__row.employing-school .govuk-summary-list__value") }
            it "renders" do
              expect(subject).to have_text(trainee.employing_school.name)
              expect(subject).to have_text(trainee.employing_school.urn)
              expect(subject).to have_text(trainee.employing_school.town)
              expect(subject).to have_text(trainee.employing_school.postcode)
            end

            it "has correct change links" do
              expect(component).to have_link(href: "/trainees/#{trainee.slug}/employing-schools/edit")
            end
          end
        end

        context "when trainee is on a school direct tuition fee route" do
          let(:trainee) { create(:trainee, lead_school: school1, employing_school: school2, training_route: 3) }

          describe "lead school" do
            subject { component.find(".govuk-summary-list__row.lead-school .govuk-summary-list__value") }
            it "renders" do
              expect(subject).to have_text(trainee.lead_school.name)
              expect(subject).to have_text(trainee.lead_school.urn)
              expect(subject).to have_text(trainee.lead_school.town)
              expect(subject).to have_text(trainee.lead_school.postcode)
            end

            it "has correct change links" do
              expect(component).to have_link(href: "/trainees/#{trainee.slug}/lead-schools/edit")
            end
          end

          describe "employing school" do
            it "does not render" do
              expect(component).to_not have_text(trainee.employing_school.name)
              expect(component).to_not have_text(trainee.employing_school.urn)
              expect(component).to_not have_text(trainee.employing_school.town)
              expect(component).to_not have_text(trainee.employing_school.postcode)
            end
          end
        end
      end
    end
  end
end
