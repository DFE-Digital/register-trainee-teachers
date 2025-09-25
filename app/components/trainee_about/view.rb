# frozen_string_literal: true

module TraineeAbout
  class View < ApplicationComponent
    include Pundit::Authorization

    attr_reader :trainee, :current_user, :has_missing_fields

    def initialize(trainee:, current_user:, has_missing_fields: false)
      @trainee            = trainee
      @current_user       = current_user
      @has_missing_fields = has_missing_fields
    end

    def display_record_actions?
      @display_record_actions ||= policy(trainee).allow_actions?
    end

    def trainee_editable?
      @trainee_editable ||= policy(trainee).update?
    end
  end
end
