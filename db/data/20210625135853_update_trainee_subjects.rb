# frozen_string_literal: true

class UpdateTraineeSubjects < ActiveRecord::Migration[6.1]
  MAPPING = {
    "Art and design" => CodeSets::CourseSubjects::CREATIVE_ARTS_AND_DESIGN,
    "Biology" => CodeSets::CourseSubjects::BIOLOGY,
    "Business studies" => CodeSets::CourseSubjects::BUSINESS_STUDIES,
    "Chemistry" => CodeSets::CourseSubjects::CHEMISTRY,
    "Communication and media studies" => CodeSets::CourseSubjects::MEDIA_AND_COMMUNICATION_STUDIES,
    "Drama" => CodeSets::CourseSubjects::DRAMA,
    "Economics" => CodeSets::CourseSubjects::ECONOMICS,
    "English" => CodeSets::CourseSubjects::ENGLISH_STUDIES,
    "Health and social care" => CodeSets::CourseSubjects::HEALTH_AND_SOCIAL_CARE,
    "History" => CodeSets::CourseSubjects::HISTORY,
    "Mathematics" => CodeSets::CourseSubjects::MATHEMATICS,
    "Modern languages (other)" => CodeSets::CourseSubjects::MODERN_LANGUAGES,
    "Music" => CodeSets::CourseSubjects::MUSIC_EDUCATION_AND_TEACHING,
    "Physics" => CodeSets::CourseSubjects::PHYSICS,
    "Primary" => CodeSets::CourseSubjects::PRIMARY_TEACHING,
    "Psychology" => CodeSets::CourseSubjects::PSYCHOLOGY,
    "Religious education" => CodeSets::CourseSubjects::RELIGIOUS_STUDIES,
    "Science" => CodeSets::CourseSubjects::GENERAL_SCIENCES,
    "Spanish" => CodeSets::CourseSubjects::SPANISH_LANGUAGE,
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
