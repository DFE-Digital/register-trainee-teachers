# frozen_string_literal: true

require "rails_helper"

RSpec.describe Dttp::Provider, type: :model do
  subject { create(:dttp_provider) }

  it { is_expected.to have_db_index(:dttp_id) }


  describe "#search_by_name" do
    let!(:matching_provider) { create(:dttp_provider, name: "Test 1") }

    subject { described_class.search_by_name(search_term) }

    context "with an exactly matching name" do
      let(:search_term) { "Test 1" }
      it { is_expected.to contain_exactly(matching_provider) }
    end

    context "with partial search term" do
      let(:search_term) { "test" }
      it { is_expected.to contain_exactly(matching_provider) }
    end
  end
end
