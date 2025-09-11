# frozen_string_literal: true

module CsvFields
  class View < ApplicationComponent
    include SummaryHelper

    FIELD_DEFINITION_PATH = Rails.root.join("app/views/bulk_update/add_trainees/reference_docs/fields.yaml")

    attr_reader :fields

    def initialize
      @fields = YAML.load_file(FIELD_DEFINITION_PATH)
    end
  end
end
