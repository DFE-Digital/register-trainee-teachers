# frozen_string_literal: true

module Dttp
  module Accounts
    class Fetch
      include ServicePattern

      class HttpError < StandardError; end

      attr_reader :dttp_id

      def initialize(dttp_id:)
        @dttp_id = dttp_id
      end

      def call
        response = Client.get("/accounts(#{dttp_id})")

        if response.code != 200
          raise HttpError, "status: #{response.code}, body: #{response.body}, headers: #{response.headers}"
        end

        account_data = JSON(response.body)

        Dttp::Account.new(account_data: account_data)
      end
    end
  end
end
