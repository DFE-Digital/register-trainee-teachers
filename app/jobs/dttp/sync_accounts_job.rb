# frozen_string_literal: true

module Dttp
  class SyncAccountsJob < ApplicationJob
    queue_as :dttp

    def perform(request_uri = nil)
      @account_list = RetrieveAccounts.call(request_uri:)

      Account.upsert_all(account_attributes, unique_by: :dttp_id)

      Dttp::SyncAccountsJob.perform_later(next_page_url) if next_page?
    end

  private

    attr_reader :account_list

    def account_attributes
      Parsers::Account.to_account_attributes(accounts: account_list[:items])
    end

    def next_page_url
      account_list[:meta][:next_page_url]
    end

    def next_page?
      next_page_url.present?
    end
  end
end
