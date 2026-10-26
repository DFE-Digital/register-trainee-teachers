# frozen_string_literal: true

module Cacheable
  extend ActiveSupport::Concern

  class InvalidKeyError < StandardError; end

  def self.skip_reads(&)
    Current.set(skip_cacheable_reads: true, &)
  end

  included do
    class << self
      def get(id, key)
        return if Current.skip_cacheable_reads

        solid_cache_value = Rails.cache.read(cache_key_for(id, key))

        if solid_cache_value.present?
          track_read(key, :solid_cache_hit)
          return JSON.parse(solid_cache_value)
        end

        redis_value = redis.get(cache_key_for(id, key))
        value = JSON.parse(redis_value) if redis_value.present?

        track_read(key, value.present? ? :redis_hit : :miss)
        value
      end

      def set(id, key, values)
        raise(InvalidKeyError) unless self::FORM_SECTION_KEYS.include?(key)

        json = values.to_json

        redis.set(cache_key_for(id, key), json)
        track_write(key, :redis)

        Rails.cache.write(cache_key_for(id, key), json)
        track_write(key, :solid_cache)

        true
      end

      def clear_all(id)
        keys = self::FORM_SECTION_KEYS.map { |key| cache_key_for(id, key) }

        keys.each { |key| redis.set(key, nil) }
        Rails.cache.delete_multi(keys)
      end

      def cache_key_for(id, key)
        if ENV["TEST_ENV_NUMBER"].present?
          "#{id}_#{key}_#{ENV['TEST_ENV_NUMBER']}"
        else
          "#{id}_#{key}"
        end
      end

      def redis
        RedisSetup::RedisClient.current
      end

      def track_read(key, outcome)
        Yabeda.form_store.reads_total.increment({ key:, outcome: })
      end

      def track_write(key, backend)
        Yabeda.form_store.writes_total.increment({ key:, backend: })
      end
    end
  end
end
