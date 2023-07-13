# frozen_string_literal: true

module ReviewDraft
  module Draft
    class View < ComponentBase
      include TraineeHelper
      include TaskListHelper
      include FundingHelper

      attr_reader :trainee

      def initialize(trainee:)
        @trainee = trainee
      end
    end
  end
end
