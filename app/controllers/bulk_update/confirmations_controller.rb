# frozen_string_literal: true

module BulkUpdate
  class ConfirmationsController < ApplicationController
    before_action { require_feature_flag(:bulk_placements) }

    def show; end
  end
end
