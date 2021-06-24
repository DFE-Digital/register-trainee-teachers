# frozen_string_literal: true

module Dttp
  module Accounts
    class Fetch
      include ServicePattern

      def initialize(dttp_id:)
        @dttp_id = dttp_id
      end

      def call
        Dttp::Account.new(account_data: JSON(response.body))
      end

    private

      attr_reader :dttp_id

      def response
        @response ||= Client.get("/accounts(#{dttp_id})")
      end
    end
  end
end
