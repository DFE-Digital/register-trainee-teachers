# frozen_string_literal: true

module BulkUpdate
  module TraineeUploads
    module HelpWithCsv
      class View < ApplicationComponent
        def headers
          BulkUpdate::AddTrainees::ImportRows::ALL_HEADERS.keys
        end
      end
    end
  end
end
