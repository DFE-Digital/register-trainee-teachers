# frozen_string_literal: true

module ReferenceData
  FUND_CODES = ReferenceData::Loader.instance.find(:fund_code)
  STUDY_MODES = ReferenceData::Loader.instance.find(:study_mode)
  TRAINING_ROUTES = ReferenceData::Loader.instance.find(:training_route)
  TRAINING_INITIATIVES = ReferenceData::Loader.instance.find(:training_initiative)
end
