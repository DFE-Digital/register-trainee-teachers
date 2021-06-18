# frozen_string_literal: true

require "rails_helper"

describe SystemAdmin::Dttp::Providers::Filter do
  let(:provider) { create(:dttp_provider, name: "Test 1") }

  describe "#call" do
    subject { described_class.call(providers: Dttp::Provider, params: params).all }

    context "with an exactly matching name" do
      let(:params) { { search_term: "Test 1" } }

      it { is_expected.to contain_exactly(provider) }
    end

    context "with partial search term" do
      let(:params) { { search_term: "test" } }

      it { is_expected.to contain_exactly(provider) }
    end
  end
end
