# frozen_string_literal: true

module SystemAdmin
  class TraineeUndoAwardCheck
    include ServicePattern

    def initialize(trainee)
      @trainee = trainee
    end

    def call
      dqt_trainee = Dqt::FindTeacher.call(@trainee)
    end
  end
end
