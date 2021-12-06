# frozen_string_literal: true

module BigQuery
  class EntityEvent
    CREATE_ENTITY_EVENT_TYPE = "create_entity"
    UPDATE_ENTITY_EVENT_TYPE = "update_entity"
    DELETE_ENTITY_EVENT_TYPE = "delete_entity"
    IMPORT_EVENT_TYPE = "import_entity"
    EVENT_TYPES = [
      CREATE_ENTITY_EVENT_TYPE,
      UPDATE_ENTITY_EVENT_TYPE,
      IMPORT_EVENT_TYPE,
      DELETE_ENTITY_EVENT_TYPE,
    ].freeze

    def initialize
      @event_hash = {
        environment: Rails.env,
        occurred_at: Time.zone.now.iso8601(6),
      }
      yield(self) if block_given?
    end

    delegate :as_json, to: :event_hash

    def with_type(type)
      raise("Invalid analytics event type") unless EVENT_TYPES.include?(type.to_s)

      @event_hash.merge!(
        event_type: type,
      )
    end

    def with_entity_table_name(table_name)
      @event_hash.merge!(
        entity_table_name: table_name,
      )
    end

    def with_data(hash)
      @event_hash.deep_merge!({
        data: hash_to_kv_pairs(hash),
      })
    end

  private

    attr_reader :event_hash

    def hash_to_kv_pairs(hash)
      hash.map do |(key, value)|
        value = value.to_s if value.in?([true, false])
        value = value.to_json if !value.is_a?(String) # Hash, Array or object e.g Progress

        { "key" => key, "value" => Array.wrap(value) }
      end
    end
  end
end
