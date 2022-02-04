# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe RetrieveBursaryDetails do
    subject { described_class.call }

    let(:expected_path) { "/dfe_bursarydetails" }

    it_behaves_like "dttp info retriever" do
      let(:request_headers) { { headers: { "Prefer" => "odata.maxpagesize=5000" } } }
    end
  end
end
