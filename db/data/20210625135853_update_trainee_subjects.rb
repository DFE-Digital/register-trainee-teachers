# frozen_string_literal: true

class UpdateTraineeSubjects < ActiveRecord::Migration[6.1]
  MAPPING = {
    "Art and design" => Dttp::CodeSets::CourseSubjects::CREATIVE_ARTS_AND_DESIGN,
    "Biology" => Dttp::CodeSets::CourseSubjects::BIOLOGY,
    "Business studies" => Dttp::CodeSets::CourseSubjects::BUSINESS_STUDIES,
    "Chemistry" => Dttp::CodeSets::CourseSubjects::CHEMISTRY,
    "Communication and media studies" => Dttp::CodeSets::CourseSubjects::MEDIA_AND_COMMUNICATION_STUDIES,
    "Drama" => Dttp::CodeSets::CourseSubjects::DRAMA,
    "Economics" => Dttp::CodeSets::CourseSubjects::ECONOMICS,
    "English" => Dttp::CodeSets::CourseSubjects::ENGLISH_STUDIES,
    "Health and social care" => Dttp::CodeSets::CourseSubjects::HEALTH_AND_SOCIAL_CARE,
    "History" => Dttp::CodeSets::CourseSubjects::HISTORY,
    "Mathematics" => Dttp::CodeSets::CourseSubjects::MATHEMATICS,
    "Modern languages (other)" => Dttp::CodeSets::CourseSubjects::MODERN_LANGUAGES,
    "Music" => Dttp::CodeSets::CourseSubjects::MUSIC_EDUCATION_AND_TEACHING,
    "Physics" => Dttp::CodeSets::CourseSubjects::PHYSICS,
    "Primary" => Dttp::CodeSets::CourseSubjects::PRIMARY_TEACHING,
    "Psychology" => Dttp::CodeSets::CourseSubjects::PSYCHOLOGY,
    "Religious education" => Dttp::CodeSets::CourseSubjects::RELIGIOUS_STUDIES,
    "Science" => Dttp::CodeSets::CourseSubjects::GENERAL_SCIENCES,
    "Spanish" => Dttp::CodeSets::CourseSubjects::SPANISH_LANGUAGE,
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
