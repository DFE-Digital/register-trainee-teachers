# frozen_string_literal: true

module HPITT
  module CodeSets
    module CourseSubjects
      MAPPING = {
        ::CourseSubjects::MATHEMATICS => ["Maths"],
        ::CourseSubjects::PRIMARY_TEACHING => ["Primary", "Early Years"],
        ::CourseSubjects::BUSINESS_STUDIES => ["Business Studies"],
        ::CourseSubjects::GEOGRAPHY => ["Geography"],
        ::CourseSubjects::GENERAL_SCIENCES => ["Science"],
        ::CourseSubjects::HISTORY => ["History"],
        ::CourseSubjects::ENGLISH_STUDIES => ["English"],
        ::CourseSubjects::APPLIED_COMPUTING => ["Computing"],
        ::CourseSubjects::DESIGN_AND_TECHNOLOGY => ["Design and Technology"],
        ::CourseSubjects::MODERN_LANGUAGES => ["MFL"],
        ::CourseSubjects::RELIGIOUS_STUDIES => ["RE"],
        ::CourseSubjects::MUSIC_EDUCATION_AND_TEACHING => ["Music"],
      }.freeze
    end
  end
end
