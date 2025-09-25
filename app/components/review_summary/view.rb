# frozen_string_literal: true

module ReviewSummary
  class View < ApplicationComponent
    renders_one :header

    def initialize(form:, invalid_data_view:)
      @form = form
      @invalid_data_view = invalid_data_view

      form.errors.clear unless errors_captured?
    end

    def render?
      errors_captured? || invalid_data_view.invalid_data?
    end

    def summary_component
      errors_captured? ? ErrorSummary::View : InformationSummary::View
    end

  private

    def errors_captured?
      form.errors.any?
    end

    attr_reader :invalid_data_view, :form
  end
end
