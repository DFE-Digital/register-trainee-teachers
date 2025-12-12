# frozen_string_literal: true

module BulkUpdate
  class PlacementsController < ApplicationController
    helper_method :bulk_placements_count, :organisation_filename

    def new
      respond_to do |format|
        format.html do
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
      @placements_form = PlacementsForm.new(provider: organisation, file: file, user: current_user)

      if @placements_form.save
        redirect_to(bulk_update_placements_confirmation_path)
      else
        render(:new)
      end
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
      @bulk_placements ||= current_user.organisation.trainees_without_required_placements.includes(:placements)
    end
  end
end
