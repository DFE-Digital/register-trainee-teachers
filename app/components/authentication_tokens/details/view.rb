# frozen_string_literal: true

module AuthenticationTokens
  module Details
    class View < ViewComponent::Base
      attr_reader :token

      delegate :id,
               :name,
               :status,
               :created_by,
               :created_at,
               :expires_at,
               :last_used_at,
               :revoked_by,
               to: :token

      def initialize(token)
        @token = token
      end

      def rows
        [
          {
            key: { text: "Status" }, value: { text: status }
          },
          {
            key: { text: "Created by" }, value: { text: ("#{created_by.name} on #{created_at.to_date.to_fs(:govuk)}" if created_by.present?) }
          },
          {
            key: { text: "Last used" }, value: { text: last_used_at&.to_date&.to_fs(:govuk) }
          },
          {
            key: { text: "Revoked by" }, value: { text: revoked_by&.name }
          },
          {
            key: { text: "Expired" }, value: { text: expired_at&.to_date&.to_fs(:govuk) }
          },
        ]
      end

    private

      def expired_at
        expires_at if expires_at.present? && (expires_at < Time.zone.today)
      end
    end
  end
end
