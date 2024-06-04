# frozen_string_literal: true

module TraineeAbout
  class View < ViewComponent::Base
    include Pundit::Authorization

    attr_reader :trainee, :current_user

    def initialize(trainee:, current_user:)
      @trainee = trainee
      @current_user = current_user
    end

    def display_record_actions?
      @display_record_actions ||= policy(trainee).allow_actions?
    end

    def trainee_editable?
      @trainee_editable ||= policy(trainee).update?
    end
  end
end
