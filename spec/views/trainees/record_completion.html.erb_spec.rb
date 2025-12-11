# frozen_string_literal: true

require "rails_helper"

describe "trainees/_record_completion_filter", "feature_routes.provider_led_postgrad": true do
  before do
    without_partial_double_verification do
      allow(view).to receive_messages(
        search_path: trainees_path,
        filters: nil,
        lead_school_user?: lead_school_user?,
        lead_partner_user?: lead_partner_user?,
      )

      render
    end
  end

  context "placements enabled", feature_placements: true do
    context "with a lead partner user" do
      let(:lead_school_user?) { false }
      let(:training_partner_user?) { true }

      it "does not render the record completion filter" do
        expect(rendered).to be_empty
      end
    end

    context "with a non lead school and non lead partner user" do
      let(:lead_school_user?) { false }
      let(:training_partner_user?) { false }

      it "does render the record completion filter" do
        expect(rendered).not_to be_empty
      end
    end
  end
end
