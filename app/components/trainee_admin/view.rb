# frozen_string_literal: true

module TraineeAdmin
  class View < ViewComponent::Base
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

    def dqt_data
      return unless FeatureService.enabled?(:integrate_with_dqt)

      @dqt_data ||= Dqt::RetrieveTeacher.call(trainee:)
    rescue Dqt::Client::HttpError
      false
    end
  end
end
