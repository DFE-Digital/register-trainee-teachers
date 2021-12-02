# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe RetrievePlacementAssignments do
    subject { described_class.call }

    let(:expected_path) { "/dfe_placementassignments" }

    it_behaves_like "dttp info retriever" do
      let(:request_headers) { { headers: { "Prefer" => "odata.maxpagesize=100" } } }
    end
  end
end
