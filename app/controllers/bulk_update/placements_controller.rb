# frozen_string_literal: true

module BulkUpdate
  class PlacementsController < ApplicationController
    before_action { require_feature_flag(:bulk_placements) }

    helper_method :bulk_placements_count, :organisation_filename

    def new
      respond_to do |format|
        format.html do
          @navigation_view = ::Funding::NavigationView.new(organisation:)
        end

        format.csv do
          send_data(
            Exports::BulkPlacementExport.call(bulk_placements),
            filename: organisation_filename,
            disposition: :attachment,
          )
        end
      end
    end

  private

    def organisation
      @organisation ||= current_user.organisation
    end

    def bulk_placements_count
      @bulk_placements_count ||= bulk_placements.count
    end

    def organisation_filename
      "#{organisation.name.parameterize}-to-add-missing-prepopulated.csv"
    end

    def bulk_placements
      @bulk_placements ||= current_user.organisation.trainees_to_be_placed
    end
  end
end
