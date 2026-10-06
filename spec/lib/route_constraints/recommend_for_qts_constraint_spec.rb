# frozen_string_literal: true

require "rails_helper"

module RouteConstraints
  describe RecommendForQtsConstraint do
    describe ".matches?" do
      subject { described_class.matches?(request) }

      let(:request) { double(path_parameters: { api_version: }) }

      context "when api_version is v2026.1" do
        let(:api_version) { "v2026.1" }

        it { is_expected.to be(true) }
      end

      context "when api_version is v2027.0" do
        let(:api_version) { "v2027.0" }

        it { is_expected.to be(false) }
      end
    end
  end
end
