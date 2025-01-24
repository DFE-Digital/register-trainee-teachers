# frozen_string_literal: true

require "rails_helper"

describe ReviewDraft::Draft::View do
  include TaskListHelper

  before do
    render_inline(described_class.new(trainee:))
  end

  context "sections that appear for assessment-only trainees" do
    let(:trainee) { build(:trainee) }

    it "renders correct sections for assessment-only trainees" do
      expect(rendered_content).to have_text("Personal details")
      expect(rendered_content).to have_text("Contact details")
      expect(rendered_content).to have_text("Diversity information")
      expect(rendered_content).to have_text("Degree")
      expect(rendered_content).to have_text("Course details")
      expect(rendered_content).to have_text("Trainee ID")
    end

    it "does not render non assessment-only sections" do
      expect(rendered_content).not_to have_text("Placement details")
      expect(rendered_content).not_to have_text("Lead and employing schools")
    end
  end

  context "when the trainee is on the provider-led route", "feature_routes.provider_led_postgrad": true do
    let(:trainee) { create(:trainee, :provider_led_postgrad, :with_placement_assignment) }

    it "does not render non provider-led sections" do
      expect(rendered_content).not_to have_text("#{I18n.t('components.review_draft.draft.schools.titles.school_direct_tuition_fee')}\n")
    end
  end

  %i[school_direct_salaried school_direct_tuition_fee].each do |route|
    context "when the trainee is on the #{route} routes", "feature_routes.#{route}": true do
      let(:trainee) { create(:trainee, route) }

      it "renders additional school-direct specific sections" do
        expect(rendered_content).to have_text(lead_partner_and_employing_school_details_title(route))
      end

      it "does not render non school direct sections" do
        expect(rendered_content).not_to have_text("Placement details")
      end
    end
  end

  include_examples "rendering the funding section"
end
