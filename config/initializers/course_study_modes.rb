# frozen_string_literal: true

COURSE_STUDY_ENUMS = {
  part_time: "part_time",
  full_time: "full_time",
}.freeze

COURSE_STUDY_MODES = {
  COURSE_STUDY_ENUMS[:part_time] => 0,
  COURSE_STUDY_ENUMS[:full_time] => 1,
}.freeze
