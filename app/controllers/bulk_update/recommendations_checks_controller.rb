# frozen_string_literal: true

module BulkUpdate
  class RecommendationsChecksController < RecommendationsBaseController
    def show
      @table_row_limit = 50
    end
  end
end
