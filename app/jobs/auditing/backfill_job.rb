# frozen_string_literal: true

module Auditing
  class BackfillJob < ApplicationJob
    def perform(model:, id:, audited_changes:, user:, remote_address:)
      Audited.audit_class.as_user(user) do
        # Not ideal to be calling a private method, but it's a trade-off to allow us to create audit records
        # asynchronously. The audit gem degrades performance massively when updating 1000's of records.
        model.find(id).send(
          :write_audit,
          action: "update",
          audited_changes: audited_changes,
          remote_address: remote_address
        )
      end
    end
  end
end
