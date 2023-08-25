# frozen_string_literal: true

module Features
  module TraineeSteps
    attr_reader :trainee

    def given_a_trainee_exists(*traits, **overrides)
      @trainee ||= create(:trainee, *traits, **overrides, provider: current_user.organisation)
      raise "Factory failed to save Trainee #{trainee.attributes}" unless @trainee&.persisted?
      @trainee
    end

    def trainee_from_url
      Trainee.find_by(slug: current_path.split("/")[2])
    end
  end
end
