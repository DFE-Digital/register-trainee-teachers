# frozen_string_literal: true

module ReviewDraft
  class View < ApplicationComponent
    def initialize(trainee:)
      @trainee = trainee
    end

    def component
      if @trainee.apply_application?
        ApplyDraft::View.new(trainee: @trainee)
      else
        Draft::View.new(trainee: @trainee)
      end
    end
  end
end
