# frozen_string_literal: true

module Dttp
  module CodeSets
    module CourseStudyModes
      OTHER_FULL_TIME_MODES = [
        "11640d4b-82b4-ea11-a812-000d3ad82cac", # Change to dormant status - previously full-time
        "177e1fe8-1113-e711-80c2-0050568902d3", # Dormant - previously full-time
        "2deeadf5-aa70-e811-80f3-005056ac45bb", # Other full-time
        "967ff3ef-1113-e711-80c2-0050568902d3", # Abridged
      ].freeze

      OTHER_PART_TIME_MODES = [
        "db110557-82b4-ea11-a812-000d3ad82cac", # Change to dormant status - previously part-time
        "25e5f293-aa70-e811-80f3-005056ac45bb", # Dormant - previously part-time
      ].freeze

      MAPPING = {
        COURSE_STUDY_MODES[:part_time] => { entity_id: "97ba18db-1113-e711-80c2-0050568902d3" },
        COURSE_STUDY_MODES[:full_time] => { entity_id: "a7a68b82-1113-e711-80c2-0050568902d3" },
      }.freeze
    end
  end
end
