# frozen_string_literal: true

module Trainees
  class AdminsController < BaseController
    helper_method :trainee, :collections, :dqt_data

    def show
      return redirect_to(trainees_path) unless current_user.system_admin?

      render(layout: "trainee_record")
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

    def dqt_data
      return unless FeatureService.enabled?(:integrate_with_dqt)

      @dqt_data ||= Dqt::RetrieveTeacher.call(trainee:)
    rescue Dqt::Client::HttpError
      false
    end
  end
end
