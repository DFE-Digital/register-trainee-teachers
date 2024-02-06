# frozen_string_literal: true

module Api
  class AppendMetadata
    include ServicePattern

    def initialize(data)
      @data = data
    end

    def call
      {
        data:,
        meta:,
      }
    end

  private

    attr_reader :data

    def meta
      @meta ||= {
        current_page: data.current_page,
        total_pages: data.total_pages,
        total_count: data.total_count,
        per_page: data.limit_value,
      }
    end
  end
end
