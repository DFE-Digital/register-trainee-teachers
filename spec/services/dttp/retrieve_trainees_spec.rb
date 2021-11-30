# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe RetrieveTrainees do
    subject { described_class.call }

    let(:expected_path) { "/contacts?%24filter=_dfe_contacttypeid_value+eq+faba11c7-07d9-e711-80e1-005056ac45bb" }

    it_behaves_like "dttp info retriever" do
      let(:request_headers) { { headers: { "Prefer" => "odata.maxpagesize=50" } } }
    end

    describe "::FILTER" do
      it "has correct filter params" do
        expect(described_class::FILTER).to match({ "$filter" => "_dfe_contacttypeid_value eq faba11c7-07d9-e711-80e1-005056ac45bb" })
      end
    end
  end
end
