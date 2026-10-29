# frozen_string_literal: true

module ReviewDraft
  class View < ApplicationComponent
    def initialize(trainee:, funding_prerequisites: [], course_prerequisites: [])
      @trainee = trainee
      @funding_prerequisites = Array(funding_prerequisites)
      @course_prerequisites = Array(course_prerequisites)
    end

    def component
      if @trainee.apply_application?
        ApplyDraft::View.new(trainee: @trainee)
      else
        Draft::View.new(trainee: @trainee, funding_prerequisites: @funding_prerequisites, course_prerequisites: @course_prerequisites)
      end
    end
  end
end
