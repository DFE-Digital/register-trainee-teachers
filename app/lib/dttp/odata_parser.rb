# frozen_string_literal: true

module Dttp
  class OdataParser
    UUID_PATTERN = "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"

    class << self
      def entity_ids(batch_response:)
        batch_response.scan(/(\w+)\((#{UUID_PATTERN})\)/).uniq.to_h
      end

      def entity_id(trainee_id, response)
        entity_id = response.headers["odata-entityid"]

        if entity_id.blank?
          raise DttpIdNotReturnedError,
                "failed to retrieve the entity ID from #{response.headers} with #{response.body} for trainee: #{trainee_id}"
        end

        extract_uuid(entity_id)
      end

      def extract_uuid(string_source)
        uuid = string_source.match(/#{UUID_PATTERN}/).to_s

        raise DttpIdNotReturnedError, "failed to extract UUID from #{string_source} for trainee: #{trainee.id}" if uuid.blank?

        uuid
      end
    end
  end
end
