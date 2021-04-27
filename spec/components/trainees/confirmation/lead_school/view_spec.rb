# frozen_string_literal: true

require "rails_helper"

module Trainees
  module Confirmation
    module LeadSchool
      describe View do
        alias_method :component, :page

        let(:school) { create(:school, open_date: Time.zone.today) }
        let(:trainee) { create(:trainee, lead_school: school) }
        subject { component.find(".govuk-summary-list__row.lead-school .govuk-summary-list__value") }

        before do
          render_inline(View.new(data_model: trainee))
        end

        it "renders the lead school" do
          expect(subject).to have_text(trainee.lead_school.name)
          expect(subject).to have_text(trainee.lead_school.urn)
          expect(subject).to have_text(trainee.lead_school.town)
          expect(subject).to have_text(trainee.lead_school.postcode)
        end
      end
    end
  end
end
