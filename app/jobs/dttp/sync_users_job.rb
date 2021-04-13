# frozen_string_literal: true

module Dttp
  class SyncUsersJob < ApplicationJob
    queue_as :dttp

    def perform(path = nil)
      @user_list = Dttp::RetrieveUsers.call(path: path)

      Dttp::User.upsert_all(user_attributes, unique_by: :dttp_id)

      Dttp::SyncUsersJob.perform_later(next_page_url) if next_page_url.present?
    end

  private

    attr_reader :user_list

    def user_attributes
      Dttp::Parsers::Contact.to_user_attributes(contacts: user_list[:items])
    end

    def next_page_url
      user_list[:meta][:next_page_url]
    end
  end
end
