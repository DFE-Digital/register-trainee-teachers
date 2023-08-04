# frozen_string_literal: true

class TraineeSafeToUnaward
  include ServicePattern

  def initialize(trainee)
    @trainee = trainee
  end

  def call
    dqt_trainee = Dqt::RetrieveTraining.call(trainee: @trainee)
    dqt_trainee.present? && dqt_trainee["result"] != "Pass"
  end
end
