# frozen_string_literal: true

module CsvDocs
  class BaseController < ::ApplicationController
    skip_before_action :authenticate
    before_action { require_feature_flag(:bulk_add_trainees) }
  end
end
