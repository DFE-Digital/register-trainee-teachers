# frozen_string_literal: true

COURSE_STUDY_MODES = {
  part_time: "part_time",
  full_time: "full_time",
  full_time_or_part_time: "full_time_or_part_time",
}.freeze

TRAINEE_STUDY_MODE_ENUMS = {
  COURSE_STUDY_MODES[:part_time] => 0,
  COURSE_STUDY_MODES[:full_time] => 1,
}.freeze

COURSE_STUDY_MODE_ENUMS = {
  COURSE_STUDY_MODES[:part_time] => 0,
  COURSE_STUDY_MODES[:full_time] => 1,
  COURSE_STUDY_MODES[:full_time_or_part_time] => 2,
}.freeze
