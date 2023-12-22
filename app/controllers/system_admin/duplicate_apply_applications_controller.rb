# frozen_string_literal: true

module SystemAdmin
  class DuplicateApplyApplicationsController < ApplicationController
    def index
      @apply_applications = ApplyApplication
        .non_importable_duplicate
        .where(recruitment_cycle_year: Settings.current_recruitment_cycle_year)
    end

    def show; end
  end
end
