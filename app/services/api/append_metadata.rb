# frozen_string_literal: true

module Api
  class AppendMetadata
    include ServicePattern

    def initialize(objects, model, version)
      @objects = objects
      @model = model
      @version = version
    end

    def call
      {
        data:,
        meta:,
      }
    end

  private

    attr_reader :objects, :model, :version

    def meta
      @meta ||= {
        current_page: objects.current_page,
        total_pages: objects.total_pages,
        total_count: objects.total_count,
        per_page: objects.limit_value,
      }
    end

    def data
      @data ||= objects.each do |object|
        Serializer.for(model:, version:).new(object).as_hash
      end
    end
  end
end
