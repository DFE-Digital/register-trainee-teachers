# frozen_string_literal: true

module Cacheable
  extend ActiveSupport::Concern

  class InvalidKeyError < StandardError; end

  included do
    class << self
      def get(id, key)
        value = redis.get(cache_key_for(id, key))
        JSON.parse(value) if value.present?
      end

      def set(id, key, values)
        raise(InvalidKeyError) unless self::FORM_SECTION_KEYS.include?(key)

        redis.set(cache_key_for(id, key), values.to_json)

        true
      end

      def clear_all(id)
        self::FORM_SECTION_KEYS.each do |key|
          redis.set(cache_key_for(id, key), nil)
        end
      end

      def cache_key_for(id, key)
        if ENV["TEST_ENV_NUMBER"].present?
          "#{id}_#{key}_#{ENV['TEST_ENV_NUMBER']}"
        else
          "#{id}_#{key}"
        end
      end

      def redis
        RedisClient.current
      end
    end
  end
end
