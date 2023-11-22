# frozen_string_literal: true

module BulkUpdate
  class PlacementsController < ApplicationController
    before_action { require_feature_flag(:bulk_placements) }

    helper_method :bulk_placements_count, :organisation_filename

    def new
      @navigation_view = ::Funding::NavigationView.new(organisation:)
    end

  private

    def organisation
      @organisation ||= current_user.organisation
    end

    def bulk_placements_count
      @bulk_placements_count ||= current_user.organisation.trainees.without_placements.count
    end

    def organisation_filename
      "#{organisation.name.parameterize}-to-add-missing-prepopulated.csv"
    end
  end
end
