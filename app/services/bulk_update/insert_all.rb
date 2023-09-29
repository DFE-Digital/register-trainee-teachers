module BulkUpdate
  class InsertAll
    include ServicePattern

    def initialize(original:, modified:, model:, unique_by:)
      @original = original.with_indifferent_access
      @modified = modified.with_indifferent_access
      @model = model
      @unique_by = unique_by
    end

    def call
      upsert_records
      enqueue_audit_jobs
      enqueue_analytics_job
    end

  private

    attr_reader :original, :modified, :model, :unique_by

    def upsert_records
      model.upsert_all(modified.values, unique_by:)
    end

    def enqueue_audit_jobs
      audit_changes.each do |id, attrs|
        AuditingJob.perform_later(
          model: model,
          id: id,
          changes: attrs,
          user: Audited.store[:current_user]&.call,
          remote_address: Audited.store[:current_remote_address],
        )
      end
    end

    # Generates the changes between original and modified records
    # Constructs a hash where each key-value pair contains the attribute and an array of [original_value, modified_value]
    def audit_changes
      @audit_changes ||= modified.each_with_object({}) do |(id, mod_attrs), result|
        original_attrs = original[id]
        result[id] = {}.with_indifferent_access

        mod_attrs.each do |attr, mod_value|
          next if original_attrs[attr] == mod_value

          orig_value, new_value = convert_enum(attr, original_attrs[attr], mod_value)
          result[id][attr] = [orig_value, new_value]
        end
      end
    end

    # Handles enum conversion for given attribute and values
    # Returns an array containing the original and modified values, converted to integers if the attribute is an enum
    def convert_enum(attr, original_value, modified_value)
      if model.defined_enums.key?(attr.to_s)
        [model.defined_enums[attr.to_s][original_value.to_s], model.defined_enums[attr.to_s][modified_value.to_s]]
      else
        [original_value, modified_value]
      end
    end

    def ids
      @ids ||= modified.keys
    end

    def enqueue_analytics_job
      AnalyticsJob.perform_later(model:, ids:)
    end
  end
end
