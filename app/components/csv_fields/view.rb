# frozen_string_literal: true

module CsvFields
  class View < ViewComponent::Base
    include SummaryHelper

    attr_reader :fields

    FIELD_DEFINITION_PATH = Rails.root.join("app/views/bulk_update/add_trainees/reference_docs/fields.yaml")

    def initialize
      @fields = YAML.load_file(FIELD_DEFINITION_PATH)
    end
  end
end
