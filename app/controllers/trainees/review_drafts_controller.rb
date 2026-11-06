# frozen_string_literal: true

module Trainees
  class ReviewDraftsController < BaseController
    prepend_before_action :ensure_trainee_is_draft!

    def show
      page_tracker.save_as_origin!
      @funding_prerequisites = funding_prerequisites
      @course_prerequisites = course_prerequisites
    end

  private

    # Set when a funding page sent the provider back (FundingPrerequisitesCheckable).
    # Worked out again, so it goes once the degree or employing school is added.
    def funding_prerequisites
      return [] if flash[:funding_prerequisites].blank?

      FundingManager.new(trainee).funding_prerequisites
    end

    # Set when a course details page sent the provider back (CoursePrerequisitesCheckable).
    def course_prerequisites
      return [] if flash[:course_prerequisites].blank?

      Trainees::CoursePrerequisites.missing(trainee)
    end
  end
end
