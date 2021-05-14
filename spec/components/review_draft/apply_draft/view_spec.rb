# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReviewDraft::ApplyDraft::View do
  alias_method :component, :page

  describe "sections that appear for application draft trainee" do
    before do
      render_inline(described_class.new(trainee: trainee))
    end

    context "when the trainee is on the provider-led route", 'feature_routes.provider_led_postgrad': true do
      let(:trainee) { create(:trainee, :provider_led_postgrad, :with_placement_assignment, :with_apply_application) }

      it "renders the correct provider-led sections" do
        expect(component).to have_text("Course details")
        expect(component).to have_text("Trainee data")
        expect(component).to have_text("Placement details")
        expect(component).to have_text("Training details")
      end

      it "does not render non provider-led sections" do
        expect(component).to_not have_text("Lead and employing schools")
      end
    end

    %i[school_direct_salaried school_direct_tuition_fee].each do |route|
      context "when the trainee is on the #{route} routes", "feature_routes.#{route}": true do
        let(:trainee) { create(:trainee, route, :with_apply_application) }

        it "renders the correct school direct sections" do
          expect(component).to have_text("Course details")
          expect(component).to have_text("Trainee data")
          expect(component).to have_text("Training details")
          expect(component).to have_text("Lead and employing schools")
        end

        it "does not render non school-direct sections" do
          expect(component).to_not have_text("Placement details")
        end
      end
    end
  end
end
