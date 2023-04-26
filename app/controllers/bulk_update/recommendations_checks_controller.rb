# frozen_string_literal: true

module BulkUpdate
  class RecommendationsChecksController < RecommendationsBaseController
    def show
      @table_row_limit = 50
      @rows = recommendations_upload.awardable_rows.includes(:trainee).order(:csv_row_number)
    end
  end
end
