# frozen_string_literal: true

require "rails_helper"

describe PerformanceProfileBanner::View do
  let(:previous_academic_cycle) { create(:academic_cycle, previous_cycle: true) }
  let(:previous_academic_cycle_label) { previous_academic_cycle.label }
  let(:sign_off_period) { :census_period }

  let(:provider_awaiting_sign_off) { OpenStruct.new(performance_signed_off?: false) }

  let(:provider_performance_signed_off) { OpenStruct.new(performance_signed_off?: true) }

  before do
    @result = render_inline(PerformanceProfileBanner::View.new(previous_academic_cycle:, sign_off_period:, provider:))
  end

  context "census_period" do
    let(:sign_off_period) { :census_period }
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

  context "performance_period_signed_off" do
    let(:sign_off_period) { :performance_period }
    let(:provider) { provider_performance_signed_off }

    it "renders nothing" do
      expect(@result.text).to be_blank
    end
  end

  context "performance_period_awaiting_sign_off" do
    let(:sign_off_period) { :performance_period }
    let(:provider) { provider_awaiting_sign_off }

    it "renders correctly" do
      expect(@result).to have_css("#govuk-notification-banner-title", text: "Important")
      expect(@result).to have_css(".govuk-notification-banner__heading", text: "The #{previous_academic_cycle_label} ITT performance profile sign off due")
    end

    it "renders the link correctly" do
      expect(@result).to have_link("Sign off your performance profile", href: "#")
    end
  end
end
