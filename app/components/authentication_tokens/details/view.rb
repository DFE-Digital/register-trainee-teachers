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
               :revoked_at,
               :revoked?,
               :expired?,
               to: :token

      def initialize(token)
        @token = token
      end

      def rows
        row = [
          {
            key: { text: "Status" }, value: { text: status.capitalize }
          },
          {
            key: { text: "Created by" }, value: { text: ("#{created_by.name} on #{created_at.to_date.to_fs(:govuk)}" if created_by.present?) }
          },
          {
            key: { text: "Last used" }, value: { text: last_used_at&.to_date&.to_fs(:govuk) }
          },
        ]

        if revoked?
          row += [
            {
              key: { text: "Revoked by" }, value: { text: "#{revoked_by.name} on #{revoked_at.to_date.to_fs(:govuk)}" }
            },
          ]
        end

        if expires_at.present?
          row += [
            {
              key: { text: expired? ? "Expired" : "Expires at" }, value: { text: expires_at.to_fs(:govuk) }
            },
          ]
        end

        row
      end
    end
  end
end
