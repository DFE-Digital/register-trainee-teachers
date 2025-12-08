# frozen_string_literal: true

module ReferenceData
  COURSE_AGE_RANGES = ReferenceData::Loader.instance.find(:course_age_range)
  ETHNICITIES = ReferenceData::Loader.instance.find(:ethnicity)
  FUND_CODES = ReferenceData::Loader.instance.find(:fund_code)
  SEXES = ReferenceData::Loader.instance.find(:sex)
  STUDY_MODES = ReferenceData::Loader.instance.find(:study_mode)
  TRAINING_ROUTES = ReferenceData::Loader.instance.find(:training_route)
end
