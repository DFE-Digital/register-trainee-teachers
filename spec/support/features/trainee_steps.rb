module Features
  module TraineeSteps
    attr_reader :trainee

    def given_a_trainee_exists(attributes = {})
      @trainee ||= create(:trainee, **attributes, provider: current_user.provider)
    end
  end
end
