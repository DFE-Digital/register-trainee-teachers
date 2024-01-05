# frozen_string_literal: true

module SystemAdmin
  class DuplicateApplyApplicationsController < ApplicationController
    def index
      @apply_applications = ApplyApplication
        .non_importable_duplicate
        .where(recruitment_cycle_year: Settings.current_recruitment_cycle_year)
        .order(created_at: :desc)
        .page(params[:page] || 1)
    end

    def show
      @apply_application = ApplyApplication.find(params[:id])
      @candidate_name = @apply_application.candidate_full_name

      @duplicate_trainees = Trainees::FindDuplicates.call(application_record: @apply_application)
      @exact_duplicates = @duplicate_trainees.present?
      @duplicate_trainees = Trainees::FindPotentialDuplicates.call(application_record: @apply_application) if @duplicate_trainees.blank?

      @duplicate_trainees = [@duplicate_trainees.last].compact
    end
  end
end
