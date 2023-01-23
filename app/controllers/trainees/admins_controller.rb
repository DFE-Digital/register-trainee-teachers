# frozen_string_literal: true

module Trainees
  class AdminsController < BaseController
    helper_method :trainee, :collections

    def show
      return redirect_to(trainees_path) unless current_user.system_admin?

      render(layout: "trainee_record")
    end

  private

    def collections
      @collections ||= Hesa::Student.distinct.pluck(:collection_reference).sort.reverse
    end
  end
end
