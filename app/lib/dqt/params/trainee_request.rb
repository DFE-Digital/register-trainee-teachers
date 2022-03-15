# frozen_string_literal: true

module Dqt
  module Params
    class TraineeRequest < TrnRequest
    private

      def build_params
        {
          "trn" => trainee.trn,
          "birthDate" => trainee.date_of_birth.iso8601,
          "initialTeacherTraining" => initial_teacher_training_params,
          "qualification" => qualification_params,
        }
      end
    end
  end
end
