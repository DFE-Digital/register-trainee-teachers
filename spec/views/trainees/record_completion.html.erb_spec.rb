# frozen_string_literal: true

require "rails_helper"

describe "trainees/_record_completion_filter", "feature_routes.provider_led_postgrad": true do
  before do
    without_partial_double_verification do
      allow(view).to receive(:search_path).and_return(trainees_path)
      allow(view).to receive(:filters).and_return(nil)
      allow(view).to receive(:lead_school_user?).and_return(lead_school_user?)
      render
    end
  end

  context "placements enabled", feature_placements: true do
    context "with a lead school users" do
      let(:lead_school_user?) { true }

      it "does not render the record completion filter" do
        expect(rendered).to be_empty
      end
    end

    context "with a non lead school user" do
      let(:lead_school_user?) { false }

      it "does render the record completion filter" do
        expect(rendered).not_to be_empty
      end
    end
  end
end
