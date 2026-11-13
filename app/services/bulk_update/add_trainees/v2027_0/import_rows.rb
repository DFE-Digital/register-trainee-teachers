# frozen_string_literal: true

module BulkUpdate
  module AddTrainees
    module V20270
      class ImportRows < BulkUpdate::AddTrainees::V20261::ImportRows
        def self.fields_definition_path
          BulkUpdate::AddTrainees::V20261::ImportRows.fields_definition_path
        end
      end
    end
  end
end
