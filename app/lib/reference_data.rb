# frozen_string_literal: true

module ReferenceData
  TRAINEE_STUDY_MODES = ReferenceData::Loader.instance.find(:trainee_study_mode)
  TRAINING_ROUTES = ReferenceData::Loader.instance.find(:training_route)
end
