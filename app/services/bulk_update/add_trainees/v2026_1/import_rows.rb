# frozen_string_literal: true

module BulkUpdate
  module AddTrainees
    module V20261
      class ImportRows < V20260::ImportRows
        EMPTY_CSV_TEMPLATE_PATH = "/csv/v2026_1/bulk_create_trainee.csv"
      end
    end
  end
end
