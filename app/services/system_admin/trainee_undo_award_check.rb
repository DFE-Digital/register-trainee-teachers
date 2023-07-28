# frozen_string_literal: true

module SystemAdmin
  class TraineeUndoAwardCheck
    include ServicePattern

    def initialize(trainee)
      @trainee = trainee
    end

    def call
      dqt_trainee = Dqt::RetrieveTraining.call(trainee: @trainee)
      dqt_trainee.present? && dqt_trainee["result"] == "Pass"
    end
  end
end
