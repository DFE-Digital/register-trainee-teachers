# frozen_string_literal: true

module BulkUpdate
  class UpsertAll
    include ServicePattern

    def initialize(original:, modified:, model:, unique_by:)
      @original = original.with_indifferent_access
      @modified = modified.with_indifferent_access
      @model = model
      @unique_by = unique_by
    end

    def call
      result = upsert_records
      enqueue_audit_jobs
      enqueue_analytics_job
      result
    end

  private

    attr_reader :original, :modified, :model, :unique_by

    def upsert_records
      model.upsert_all(modified.values, unique_by: unique_by, returning: :id)
    end

    def enqueue_audit_jobs
      user = Audited.store[:current_user]&.call
      remote_address = Audited.store[:current_remote_address]

      audit_changes.each do |id, audited_changes|
        AuditingJob.perform_later(model:, id:, audited_changes:, user:, remote_address:)
      end
    end

    # Generates the changes between original and modified records
    # Constructs a hash where each key-value pair contains the attribute and an array of [original_value, modified_value]
    def audit_changes
      @audit_changes ||= modified.each_with_object({}) do |(id, mod_attrs), result|
        original_attrs = original[id]

        differences = mod_attrs.each_with_object({}.with_indifferent_access) do |(attr, mod_value), diff|
          next if original_attrs[attr] == mod_value

          orig_value, new_value = convert_enums_to_integers(attr, original_attrs[attr], mod_value)
          diff[attr] = [orig_value, new_value]
        end

        result[id] = differences unless differences.empty?
      end
    end

    def convert_enums_to_integers(attr, original_value, modified_value)
      if model.defined_enums.key?(attr.to_s)
        [model.defined_enums[attr.to_s][original_value.to_s], model.defined_enums[attr.to_s][modified_value.to_s]]
      else
        [original_value, modified_value]
      end
    end

    def enqueue_analytics_job
      ids = modified.keys

      AnalyticsJob.perform_later(model:, ids:)
    end
  end
end
