# frozen_string_literal: true

module TraineeAdmin
  class View < ApplicationComponent
    include Pundit::Authorization

    attr_reader :trainee, :current_user

    def initialize(trainee:, current_user:)
      @trainee = trainee
      @current_user = current_user
    end

    def collections
      @collections ||= ::Hesa::Student.where
                                      .not(collection_reference: nil)
                                      .distinct
                                      .pluck(:collection_reference)
                                      .sort
                                      .reverse
    end

    def trs_data
      return unless FeatureService.enabled?(:integrate_with_trs)

      @trs_data ||= Trs::RetrieveTeacher.call(trainee:)
    rescue Trs::Client::HttpError
      false
    end
  end
end
