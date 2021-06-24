# frozen_string_literal: true

require "rails_helper"

module Dttp
  module Accounts
    describe Fetch do
      let(:path) { "/accounts(#{dttp_id})" }

      include_examples "dttp info fetcher", Dttp::Account
    end
  end
end
