# frozen_string_literal: true

module Dttp
  class Account
    def initialize(account_data:)
      @account_data = account_data
    end

    def name
      account_data["name"]
    end

    def last_updated
      account_data["modifiedon"]
    end

  private

    attr_reader :account_data
  end
end
