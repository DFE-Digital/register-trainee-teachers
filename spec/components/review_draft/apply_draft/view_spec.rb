# frozen_string_literal: true

require "rails_helper"

describe ReviewDraft::ApplyDraft::View do
  include TaskListHelper

  describe "sections that appear for application draft trainee" do
    before do
      render_inline(described_class.new(trainee:))
    end

    %i[school_direct_salaried school_direct_tuition_fee].each do |route|
      context "when the trainee is on the #{route} routes", "feature_routes.#{route}": true do
        let(:trainee) { build(:trainee, route, :with_apply_application) }

        it "renders the correct school direct sections" do
          expect(rendered_content).to have_text("Course details")
          expect(rendered_content).to have_text("Trainee data")
          expect(rendered_content).to have_text("Trainee ID")
          expect(rendered_content).to have_text(lead_partner_and_employing_school_details_title(route))
        end

        it "does not render non school-direct sections" do
          expect(rendered_content).not_to have_text("Placement details")
        end
      end
    end

    it_behaves_like "rendering the funding section"
  end
end
