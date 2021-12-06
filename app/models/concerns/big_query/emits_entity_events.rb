# frozen_string_literal: true

module BigQuery
  module EmitsEntityEvents
    extend ActiveSupport::Concern

    included do
      attr_accessor :event_tags

      after_create do
        if big_query_enabled?
          data = entity_data(attributes)
          send_event(build_event(BigQuery::EntityEvent::CREATE_ENTITY_EVENT_TYPE, data)) if data.any?
        end
      end

      after_update do
        if big_query_enabled?
          # in this after_update hook we don’t have access to the new fields via
          # #attributes — we need to dig them out of saved_changes which stores
          # them in the format { attr: ['old', 'new'] }

          interesting_changes = entity_data(saved_changes.transform_values(&:last))

          if interesting_changes.any?
            send_event(
              build_event(BigQuery::EntityEvent::UPDATE_ENTITY_EVENT_TYPE, entity_data(attributes).merge(interesting_changes)),
            )
          end
        end
      end

      after_destroy do
        if big_query_enabled?
          data = entity_data(attributes)
          if data.any?
            send_event(
              build_event(BigQuery::EntityEvent::DELETE_ENTITY_EVENT_TYPE, data),
            )
          end
        end
      end
    end

    def send_import_event
      build_event(BigQuery::EntityEvent::IMPORT_EVENT_TYPE, entity_data(attributes)).tap do |event|
        send_event(event)
      end
    end

  private

    def send_event(event)
      return unless big_query_enabled?

      SendEventJob.perform_later(event_json: event.as_json)
    end

    def entity_data(changeset)
      exportable_attrs = Rails.configuration.analytics[self.class.table_name.to_sym]
      changeset.slice(*exportable_attrs&.map(&:to_s))
    end

    def build_event(type, data)
      BigQuery::EntityEvent.new do |ee|
        ee.with_type(type)
        ee.with_entity_table_name(self.class.table_name)
        ee.with_data(data)
      end
    end

    def big_query_enabled?
      FeatureService.enabled?("google.send_data_to_big_query")
    end
  end
end
