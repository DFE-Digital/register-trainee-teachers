# frozen_string_literal: true

module ReferenceData
  COUNTRIES = ReferenceData::Loader.instance.find(:country)
  COURSE_AGE_RANGES = ReferenceData::Loader.instance.find(:course_age_range)
  COURSE_SUBJECTS = ReferenceData::Loader.instance.find(:course_subject)
  DEGREE_SUBJECTS = ReferenceData::Loader.instance.find(:degree_subject)
  DEGREE_GRADES = ReferenceData::Loader.instance.find(:degree_grade)
  DEGREE_TYPES = ReferenceData::Loader.instance.find(:degree_type)
  DISABILITIES = ReferenceData::Loader.instance.find(:disability)
  ETHNICITIES = ReferenceData::Loader.instance.find(:ethnicity)
  FUND_CODES = ReferenceData::Loader.instance.find(:fund_code)
  INSTITUTIONS = ReferenceData::Loader.instance.find(:institution)
  ITT_AIMS = ReferenceData::Loader.instance.find(:itt_aim)
  ITT_QUALIFICATION_AIMS = ReferenceData::Loader.instance.find(:itt_qualification_aim)
  NATIONALITIES = ReferenceData::Loader.instance.find(:nationality)
  SEXES = ReferenceData::Loader.instance.find(:sex)
  STUDY_MODES = ReferenceData::Loader.instance.find(:study_mode)
  TRAINING_ROUTES = ReferenceData::Loader.instance.find(:training_route)
  TRAINING_INITIATIVES = ReferenceData::Loader.instance.find(:training_initiative)
end
