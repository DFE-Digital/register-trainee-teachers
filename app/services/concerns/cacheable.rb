# frozen_string_literal: true

module Cacheable
  extend ActiveSupport::Concern

  class InvalidKeyError < StandardError; end

  included do
    class << self
      def get(id, key)
        value = Rails.cache.read(cache_key_for(id, key))

        if value.present?
          track_read(key, :solid_cache_hit)
          JSON.parse(value)
        else
          track_read(key, :miss)
          nil
        end
      end

      def set(id, key, values)
        raise(InvalidKeyError) unless self::FORM_SECTION_KEYS.include?(key)

        Rails.cache.write(cache_key_for(id, key), values.to_json)
        track_write(key, :solid_cache)

        true
      end

      def clear_all(id)
        self::FORM_SECTION_KEYS.each do |key|
          Rails.cache.delete(cache_key_for(id, key))
        end
      end

      def cache_key_for(id, key)
        if ENV["TEST_ENV_NUMBER"].present?
          "#{id}_#{key}_#{ENV['TEST_ENV_NUMBER']}"
        else
          "#{id}_#{key}"
        end
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
