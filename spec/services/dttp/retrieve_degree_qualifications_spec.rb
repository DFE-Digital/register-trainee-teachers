# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe RetrieveDegreeQualifications do
    subject { described_class.call }

    let(:expected_path) { "/dfe_degreequalifications" }

    it_behaves_like "dttp info retriever"
  end
end
