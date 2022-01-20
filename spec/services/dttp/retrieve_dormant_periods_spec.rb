# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe RetrieveDormantPeriods do
    subject { described_class.call }

    let(:expected_path) { "/dfe_dormantperiods" }

    it_behaves_like "dttp info retriever" do
      let(:request_headers) { { headers: { "Prefer" => "odata.maxpagesize=100" } } }
    end
  end
end
