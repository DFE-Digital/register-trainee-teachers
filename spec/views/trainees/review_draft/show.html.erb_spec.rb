# frozen_string_literal: true

require "rails_helper"

describe "trainees/review_draft/show.html.erb", feature_routes_provider_led_postgrad: true do
  before do
    assign(:trainee, trainee)
    render
  end

  context "with an Assessment only trainee" do
    let(:trainee) { create(:trainee) }

    it "does not render the placement details component" do
      expect(rendered).to_not have_text("Placement details")
    end
  end

  context "with a Provider-led (postgrad) trainee" do
    let(:trainee) { create(:trainee, :provider_led_postgrad) }

    it "renders the placement details component" do
      expect(rendered).to have_text("Placement details")
    end
  end
end
