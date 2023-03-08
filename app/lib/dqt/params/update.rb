# frozen_string_literal: true

module Dqt
  module Params
    class Update < TrnRequest
    private

      def build_params
        {
          "trn" => trainee.trn,
          "husid" => trainee.hesa_id,
          "initialTeacherTraining" => initial_teacher_training_params,
          "qualification" => qualification_params,
        }
      end
    end
  end
end
