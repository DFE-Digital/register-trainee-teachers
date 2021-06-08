# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe RetrieveUsers do
    subject { described_class.call }

    let(:expected_path) { "/contacts?%24filter=dfe_portaluser+eq+true+and+statecode+eq+0&%24select=firstname%2Clastname%2Cemailaddress1%2Ccontactid%2C_parentcustomerid_value" }

    it_behaves_like "dttp info retriever"

    describe "::FILTER" do
      it "has correct filter params" do
        expect(described_class::FILTER).to match({ "$filter" => "dfe_portaluser eq true and statecode eq 0" })
      end
    end
  end
end
