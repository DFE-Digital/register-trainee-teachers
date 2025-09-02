# frozen_string_literal: true

module SystemAdmin
  class ValidationErrorsController < ApplicationController
    def index
      authorize(ValidationError, :index?)
      @grouped_counts = ValidationError.group(:form_object).order(count_all: :desc).count
      @grouped_column_error_counts = ValidationError.list_of_distinct_errors_with_count
    end
  end
end
