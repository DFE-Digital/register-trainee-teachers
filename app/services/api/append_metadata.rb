# frozen_string_literal: true

module Api
  class AppendMetadata
    include ServicePattern

    def initialize(dataset)
      @dataset = dataset
    end

    def call
      {
        set_name => dataset,
        "metadata" => metadata,
      }
    end

  private

    attr_reader :dataset

    def metadata
      {
        current_page: dataset.current_page,
        total_pages: dataset.total_pages,
        total_count: dataset.total_count,
        per_page: dataset.limit_value,
      }
    end

    def set_name
      @set_name ||= dataset.klass.table_name
    end
  end
end
