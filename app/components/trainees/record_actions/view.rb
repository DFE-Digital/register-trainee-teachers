# frozen_string_literal: true

module Trainees
  module RecordActions
    class View < GovukComponent::Base
      include ApplicationHelper

      attr_reader :trainee

      def initialize(trainee)
        @trainee = trainee
      end

      def display_actions?
        allow_defer? || allow_withdraw?
      end

      def allow_defer?
        trainee.submitted_for_trn? || trainee.trn_received?
      end

      def allow_withdraw?
        allow_defer? || trainee.deferred?
      end
    end
  end
end
