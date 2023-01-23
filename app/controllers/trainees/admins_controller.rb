# frozen_string_literal: true

module Trainees
  class AdminsController < BaseController
    helper_method :trainee

    def show
      return redirect_to(trainees_path) unless current_user.system_admin?

      render(layout: "trainee_record")
    end
  end
end
