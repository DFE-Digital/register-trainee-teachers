# frozen_string_literal: true

module ReferenceData
  COURSE_AGE_RANGES = ReferenceData::Loader.instance.find(:course_age_range)
  FUND_CODES = ReferenceData::Loader.instance.find(:fund_code)
  STUDY_MODES = ReferenceData::Loader.instance.find(:study_mode)
  TRAINING_ROUTES = ReferenceData::Loader.instance.find(:training_route)
end
