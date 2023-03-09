# frozen_string_literal: true

module Dqt
  module Params
    class Update < TrnRequest
    private

      def build_params
        {
          "trn" => trainee.trn,
          "husid" => trainee.hesa_id,
          "initialTeacherTraining" => initial_teacher_training_params.merge(outcome_params),
          "qualification" => qualification_params,
        }
      end

      def outcome_params
        { "outcome" => outcome }.compact
      end

      def outcome
        return "Deferred" if trainee.deferred?

        if in_training?
          if assessment_only_route?
            "UnderAssessment"
          else
            "InTraining"
          end
        end
      end

      def in_training?
        %w[submitted_for_trn trn_received].include?(trainee.state)
      end

      def assessment_only_route?
        trainee.training_route == TRAINING_ROUTE_ENUMS[:assessment_only]
      end
    end
  end
end
