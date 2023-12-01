# frozen_string_literal: true

module BulkUpdate
  class PlacementsController < ApplicationController
    before_action { require_feature_flag(:bulk_placements) }

    helper_method :bulk_placements_count, :organisation_filename

    def new
      respond_to do |format|
        format.html do
          @navigation_view = ::Funding::NavigationView.new(organisation:)
          @placements_form = PlacementsForm.new
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

    def create
      @placements_form = PlacementsForm.new(provider: organisation, file: file)
      @navigation_view = ::Funding::NavigationView.new(organisation:)

      if @placements_form.save
        flash.now[:success] = "Placements will be processed shortly" # rubocop:disable Rails/I18nLocaleTexts
        create_rows!
      end
      render(:new)
    end

  private

    attr_reader :placements_form

    def file
      @file ||= params.dig(:bulk_update_placements_form, :file)
    end

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
      @bulk_placements ||= current_user.organisation.without_required_placements.includes(:placements)
    end

    # for now, if anything goes wrong during creation of trainees
    # delete the recommend_upload record (and uploaded file)
    def create_rows!
      bulk_placement = @placements_form.bulk_placement

      Placements::CreatePlacementRows.call(
        bulk_placement: bulk_placement,
        csv: @placements_form.csv,
      )
    rescue StandardError => e
      bulk_placement.destroy
      raise(e)
    end
  end
end
