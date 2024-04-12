# frozen_string_literal: true

module Api
  class AppendMetadata
    include ServicePattern

    def initialize(objects:, serializer:)
      @objects    = objects
      @serializer = serializer
    end

    def call
      {
        data:,
        meta:,
      }
    end

  private

    attr_reader :objects, :serializer

    def meta
      @meta ||= {
        current_page: objects.current_page,
        total_pages: objects.total_pages,
        total_count: objects.total_count,
        per_page: objects.limit_value,
      }
    end

    def data
      @data ||= objects.map do |object|
        serializer.new(object).as_hash
      end
    end
  end
end
