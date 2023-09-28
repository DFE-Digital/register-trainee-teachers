module BulkUpdate
  class InsertAll
    include ServicePattern

    def initialize(original:, modified:, model:, unique_by:)
      @original = original
      @modified = modified
      @model = model
      @unique_by = unique_by
    end

    def call
      upsert_records
      enqueue_audit_jobs
      send_to_big_query
    end

  private

    attr_reader :original, :modified, :model, :unique_by

    def records
      @records ||= model.find(modified.keys)
    end

    def upsert_records
      model.upsert_all(modified, unique_by:)
    end

    def enqueue_audit_jobs
      audit_changes.each do |id, attrs|
        Auditing::BackfillJob.perform_later(
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

        mod_attrs.each do |attr, mod_value|
          next if original_attrs[attr] == mod_value

          orig_value, new_value = convert_enum(attr, original_attrs[attr], mod_value)
          result[attr] = [orig_value, new_value]
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

    def send_to_big_query
      DfE::Analytics::SendEvents.do(analytics_events.as_json)
    end

    def analytics_events
      @analytics_events ||= records.map do |record|
        DfE::Analytics::Event.new
                              .with_type('update_entity')
                              .with_entity_table_name(model)
                              .with_data(DfE::Analytics.extract_model_attributes(record))
      end
    end
  end
end
