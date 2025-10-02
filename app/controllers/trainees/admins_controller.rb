# frozen_string_literal: true

module Trainees
  class AdminsController < BaseController
    helper_method :trainee, :collections

    def show
      return redirect_to(trainees_path) unless current_user.system_admin?

      render("trainees/show")
    end

  private

    def collections
      @collections ||= ::Hesa::Student.where
                                      .not(collection_reference: nil)
                                      .distinct
                                      .pluck(:collection_reference)
                                      .sort
                                      .reverse
    end
  end
end
