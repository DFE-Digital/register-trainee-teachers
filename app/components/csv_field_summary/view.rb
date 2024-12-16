# frozen_string_literal: true

module CsvFieldSummary
  class View < ViewComponent::Base
    include SummaryHelper

    def initialize(attributes)
      @attributes = attributes
    end

    def summary_title
      @attributes[:field_name]
    end
  end
end
