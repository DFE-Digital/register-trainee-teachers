# frozen_string_literal: true

module TraineePersonalDetails
  class View < ApplicationComponent
    include Pundit::Authorization
    include UsersHelper

    attr_reader :trainee, :current_user

    def initialize(trainee:, current_user:)
      @trainee = trainee
      @current_user = current_user
    end

    def trainee_editable?
      @trainee_editable ||= policy(trainee).update?
    end
  end
end
