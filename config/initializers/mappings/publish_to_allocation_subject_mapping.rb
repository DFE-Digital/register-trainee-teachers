# frozen_string_literal: true

module PublishSubjects
  MODERN_LANGUAGES = "Modern Languages"
  MODERN_LANGUAGES_OTHER = "Modern languages (other)"

  ENGLISH = "English"
  FRENCH = "French"
  GERMAN = "German"
  ITALIAN = "Italian"
  JAPANESE = "Japanese"
  MANDARIN = "Mandarin"
  RUSSIAN = "Russian"
  SPANISH = "Spanish"
end

PUBLISH_LANGUAGES = [
  PublishSubjects::ENGLISH,
  PublishSubjects::FRENCH,
  PublishSubjects::GERMAN,
  PublishSubjects::ITALIAN,
  PublishSubjects::JAPANESE,
  PublishSubjects::MANDARIN,
  PublishSubjects::MODERN_LANGUAGES,
  PublishSubjects::MODERN_LANGUAGES_OTHER,
  PublishSubjects::RUSSIAN,
  PublishSubjects::SPANISH,
].freeze

PUBLISH_SUBJECT_SPECIALISM_MAPPING = {
  # Subjects with a simple 1-to-1 specialism mapping
  "Citizenship" => [CourseSubjects::CITIZENSHIP],
  "Communication and media studies" => [CourseSubjects::MEDIA_AND_COMMUNICATION_STUDIES],
  "Design and technology" => [CourseSubjects::DESIGN_AND_TECHNOLOGY],
  "Economics" => [CourseSubjects::ECONOMICS],
  "Geography" => [CourseSubjects::GEOGRAPHY],
  "History" => [CourseSubjects::HISTORY],
  "Music" => [CourseSubjects::MUSIC_EDUCATION_AND_TEACHING],
  "Philosophy" => [CourseSubjects::PHILOSOPHY],
  "Psychology" => AllocationSubjects::OTHER_SUBJECTS,
  "Social sciences" => [CourseSubjects::SOCIAL_SCIENCES],

  PublishSubjects::ENGLISH => [CourseSubjects::ENGLISH_STUDIES],
  PublishSubjects::FRENCH => [CourseSubjects::FRENCH_LANGUAGE],
  PublishSubjects::GERMAN => [CourseSubjects::GERMAN_LANGUAGE],
  PublishSubjects::ITALIAN => [CourseSubjects::ITALIAN_LANGUAGE],
  PublishSubjects::JAPANESE => [CourseSubjects::JAPANESE_LANGUAGE],
  PublishSubjects::MANDARIN => [CourseSubjects::CHINESE_LANGUAGES],
  PublishSubjects::RUSSIAN => [CourseSubjects::RUSSIAN_LANGUAGES],
  PublishSubjects::SPANISH => [CourseSubjects::SPANISH_LANGUAGE],

  # Subjects that have the same specialism mapping as an allocation subject
  PublishSubjects::MODERN_LANGUAGES => ALLOCATION_SUBJECT_SPECIALISM_MAPPING[AllocationSubjects::MODERN_LANGUAGES],
  PublishSubjects::MODERN_LANGUAGES_OTHER => ALLOCATION_SUBJECT_SPECIALISM_MAPPING[AllocationSubjects::MODERN_LANGUAGES],

  "Art and design" => ALLOCATION_SUBJECT_SPECIALISM_MAPPING[AllocationSubjects::ART_AND_DESIGN],
  "Biology" => ALLOCATION_SUBJECT_SPECIALISM_MAPPING[AllocationSubjects::BIOLOGY],
  "Business studies" => ALLOCATION_SUBJECT_SPECIALISM_MAPPING[AllocationSubjects::BUSINESS_STUDIES],
  "Chemistry" => ALLOCATION_SUBJECT_SPECIALISM_MAPPING[AllocationSubjects::CHEMISTRY],
  "Classics" => ALLOCATION_SUBJECT_SPECIALISM_MAPPING[AllocationSubjects::CLASSICS],
  "Computing" => ALLOCATION_SUBJECT_SPECIALISM_MAPPING[AllocationSubjects::COMPUTING],
  "Mathematics" => ALLOCATION_SUBJECT_SPECIALISM_MAPPING[AllocationSubjects::MATHEMATICS],
  "Drama" => ALLOCATION_SUBJECT_SPECIALISM_MAPPING[AllocationSubjects::DRAMA],

  # Primary subject and its derivatives
  "Primary" => [CourseSubjects::PRIMARY_TEACHING],
  "Primary with English" => [CourseSubjects::PRIMARY_TEACHING, CourseSubjects::ENGLISH_STUDIES],
  "Primary with geography and history" => [CourseSubjects::PRIMARY_TEACHING, CourseSubjects::GEOGRAPHY, CourseSubjects::HISTORY],
  "Primary with mathematics" => [CourseSubjects::SPECIALIST_TEACHING_PRIMARY_WITH_MATHEMETICS],
  "Primary with modern languages" => [CourseSubjects::PRIMARY_TEACHING, CourseSubjects::MODERN_LANGUAGES],
  "Primary with physical education" => [CourseSubjects::PRIMARY_TEACHING, CourseSubjects::PHYSICAL_EDUCATION],
  "Primary with science" => [CourseSubjects::PRIMARY_TEACHING, CourseSubjects::SCIENCE],
}.freeze
