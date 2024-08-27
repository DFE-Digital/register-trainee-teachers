# frozen_string_literal: true

class UpdateTraineeSubjects < ActiveRecord::Migration[6.1]
  MAPPING = {
    "Art and design" => Register::CodeSets::CourseSubjects::CREATIVE_ARTS_AND_DESIGN,
    "Biology" => Register::CodeSets::CourseSubjects::BIOLOGY,
    "Business studies" => Register::CodeSets::CourseSubjects::BUSINESS_STUDIES,
    "Chemistry" => Register::CodeSets::CourseSubjects::CHEMISTRY,
    "Communication and media studies" => Register::CodeSets::CourseSubjects::MEDIA_AND_COMMUNICATION_STUDIES,
    "Drama" => Register::CodeSets::CourseSubjects::DRAMA,
    "Economics" => Register::CodeSets::CourseSubjects::ECONOMICS,
    "English" => Register::CodeSets::CourseSubjects::ENGLISH_STUDIES,
    "Health and social care" => Register::CodeSets::CourseSubjects::HEALTH_AND_SOCIAL_CARE,
    "History" => Register::CodeSets::CourseSubjects::HISTORY,
    "Mathematics" => Register::CodeSets::CourseSubjects::MATHEMATICS,
    "Modern languages (other)" => Register::CodeSets::CourseSubjects::MODERN_LANGUAGES,
    "Music" => Register::CodeSets::CourseSubjects::MUSIC_EDUCATION_AND_TEACHING,
    "Physics" => Register::CodeSets::CourseSubjects::PHYSICS,
    "Primary" => Register::CodeSets::CourseSubjects::PRIMARY_TEACHING,
    "Psychology" => Register::CodeSets::CourseSubjects::PSYCHOLOGY,
    "Religious education" => Register::CodeSets::CourseSubjects::RELIGIOUS_STUDIES,
    "Science" => Register::CodeSets::CourseSubjects::GENERAL_SCIENCES,
    "Spanish" => Register::CodeSets::CourseSubjects::SPANISH_LANGUAGE,
  }.freeze

  def up
    MAPPING.each do |old_subject, new_subject|
      Trainee.where(course_subject_one: old_subject).update_all(course_subject_one: new_subject)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
