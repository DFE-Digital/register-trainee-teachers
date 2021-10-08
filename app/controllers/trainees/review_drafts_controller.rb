# frozen_string_literal: true

module Trainees
  class ReviewDraftsController < BaseController
    prepend_before_action :ensure_trainee_is_draft!

    def show
      page_tracker.save_as_origin!
    end
  end
end
