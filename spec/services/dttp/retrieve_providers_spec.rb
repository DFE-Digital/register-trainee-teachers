# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe RetrieveProviders do
    subject { described_class.call(request_uri: request_uri) }

    let(:expected_path) do
      "/accounts?%24filter=dfe_provider+eq+true+and+%28statecode+eq+0+and+statuscode+ne+300000002%29+and+%28_dfe_institutiontypeid_value+eq+b5ec33aa-216d-e711-80d2-005056ac45bb+or+_dfe_institutiontypeid_value+eq+b7ec33aa-216d-e711-80d2-005056ac45bb+or+_dfe_institutiontypeid_value+eq+b9ec33aa-216d-e711-80d2-005056ac45bb+or+_dfe_institutiontypeid_value+eq+bbec33aa-216d-e711-80d2-005056ac45bb+or+_dfe_institutiontypeid_value+eq+bdec33aa-216d-e711-80d2-005056ac45bb+or+_dfe_institutiontypeid_value+eq+bfec33aa-216d-e711-80d2-005056ac45bb+or+_dfe_institutiontypeid_value+eq+c1ec33aa-216d-e711-80d2-005056ac45bb+or+_dfe_institutiontypeid_value+eq+cdec33aa-216d-e711-80d2-005056ac45bb%29&%24select=name%2Cdfe_ukprn%2Caccountid"
    end

    let(:request_uri) { nil }

    it_behaves_like "dttp info retriever"
  end
end
