# frozen_string_literal: true

require "rails_helper"

describe CensusBanner::View do
  let(:previous_academic_cycle) { create(:academic_cycle, :previous) }
  let(:current_academic_cycle) { create(:academic_cycle, :current) }
  let(:current_academic_cycle_label) { current_academic_cycle.label }

  let(:sign_off_period) { :census_period }

  let(:provider_awaiting_sign_off) { create(:provider) }

  let(:census_signed_off) { create(:provider, sign_offs: [build(:sign_off, :census, academic_cycle: current_academic_cycle)]) }

  before do
    @result = render_inline(CensusBanner::View.new(current_academic_cycle:, sign_off_period:, provider:))
  end

  context "performance_profile_period" do
    let(:sign_off_period) { :performance_profile_period }
    let(:provider) { provider_awaiting_sign_off }

    it "renders nothing" do
      expect(@result.text).to be_blank
    end
  end

  context "outside_period" do
    let(:sign_off_period) { :outside_period }
    let(:provider) { provider_awaiting_sign_off }

    it "renders nothing" do
      expect(@result.text).to be_blank
    end
  end

  context "census_signed_off" do
    let(:sign_off_period) { :census_period }
    let(:provider) { census_signed_off }

    it "renders nothing" do
      expect(@result.text).to be_blank
    end
  end

  context "census_awaiting_sign_off" do
    let(:sign_off_period) { :census_period }
    let(:provider) { provider_awaiting_sign_off }

    it "renders correctly" do
      expect(@result).to have_css("#govuk-notification-banner-title", text: "Important")
      expect(@result).to have_css(".govuk-notification-banner__heading", text: "The #{current_academic_cycle_label} ITT census sign off is due")
    end

    it "renders the link correctly" do
      expect(@result).to have_link("Sign off your census trainee data", href: "/reports/censuses")
    end
  end
end
