# frozen_string_literal: true

module Auditing
  class TraineeAuditorJob < ApplicationJob
    def perform(trainee, audited_changes, user, remote_address)
      Audited.audit_model.as_user(user) do
        # Not ideal to be calling a private method, but it's a trade-off to allow us to create audit records
        # asynchronously. The audit gem degrades performance massively when updating 1000's of records.
        trainee.send(:write_audit, action: "update", audited_changes: audited_changes, remote_address: remote_address)
      end
    end
  end
end
