# frozen_string_literal: true

module Features
  module TraineeSteps
    attr_reader :trainee

    def given_a_trainee_exists(*, **)
      @trainee ||= if current_user.organisation
                     create(:trainee, *, **, provider: current_user.organisation)
                   else
                     create(:trainee, *, **)
                   end
    end

    def trainee_from_url
      Trainee.find_by(slug: current_path.split("/")[2])
    end
  end
end
