# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReviewDraft::Draft::View do
  alias_method :component, :page

  before do
    render_inline(described_class.new(trainee: trainee))
  end

  context "sections that appear for assessment-only trainees" do
    let(:trainee) { create(:trainee) }

    it "renders correct sections for assessment-only trainees" do
      expect(component).to have_text("Personal details")
      expect(component).to have_text("Contact details")
      expect(component).to have_text("Diversity information")
      expect(component).to have_text("Degree")
      expect(component).to have_text("Course details")
      expect(component).to have_text("Trainee start date and ID")
    end

    it "does not render non assessment-only sections" do
      expect(component).to_not have_text("Placement details")
      expect(component).to_not have_text("Lead and employing schools")
    end
  end

  context "when the trainee is on the provider-led route", 'feature_routes.provider_led_postgrad': true do
    let(:trainee) { create(:trainee, :provider_led_postgrad, :with_placement_assignment) }

    it "renders additional provider-led specific sections" do
      expect(component).to have_text("Placement details")
    end

    it "does not render non provider-led sections" do
      expect(component).to_not have_text("Lead and employing schools")
    end
  end

  %i[school_direct_salaried school_direct_tuition_fee].each do |route|
    context "when the trainee is on the #{route} routes", "feature_routes.#{route}": true do
      let(:trainee) { create(:trainee, route) }

      it "renders additional school-direct specific sections" do
        expect(component).to have_text("Lead and employing schools")
      end

      it "does not render non school direct sections" do
        expect(component).to_not have_text("Placement details")
      end
    end
  end
end
