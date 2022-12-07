# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe RetrieveAccounts do
    subject { described_class.call(request_uri:) }

    let(:expected_path) do
      "/accounts"
    end

    let(:request_uri) { nil }

    it_behaves_like "dttp info retriever"
  end
end
