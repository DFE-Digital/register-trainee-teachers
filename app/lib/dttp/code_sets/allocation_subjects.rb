# frozen_string_literal: true

module Dttp
  module CodeSets
    module AllocationSubjects
      ART_AND_DESIGN = "Art and design"
      BIOLOGY = "Biology"
      BUSINESS_STUDIES = "Business studies"
      CHEMISTRY = "Chemistry"
      OTHER_SUBJECTS = "Other subjects"
      CLASSICS = "Classics"
      COMPUTING = "Computing"
      PHYSICAL_EDUCATION = "Physical education"
      DESIGN_AND_TECHNOLOGY = "Design and technology"
      DRAMA = "Drama"
      ECONOMICS = "Economics"
      ENGLISH = "English"
      MODERN_LANGUAGES = "Modern languages"
      GEOGRAPHY = "Geography"
      HISTORY = "History"
      MATHEMATICS = "Mathematics"
      MUSIC = "Music"
      RELIGIOUS_EDUCATION = "Religious education"
      PHYSICS = "Physics"
      PRIMARY = "Primary"
      EARLY_YEARS_ITT = "Early years ITT"
      PRIMARY_WITH_MATHEMATICS = "Primary with mathematics"

      MAPPING = {
        ART_AND_DESIGN => {
          entity_id: "aff10516-aac2-e611-80be-00155d010316",
          subject_specialisms: [
            { name: CourseSubjects::CREATIVE_ARTS_AND_DESIGN, publish_equivalent: ART_AND_DESIGN },
            { name: CourseSubjects::GRAPHIC_DESIGN, publish_equivalent: ART_AND_DESIGN },
          ],
        },
        BIOLOGY => {
          entity_id: "b1f10516-aac2-e611-80be-00155d010316",
          subject_specialisms: [
            { name: CourseSubjects::APPLIED_BIOLOGY, publish_equivalent: BIOLOGY },
            { name: CourseSubjects::BIOLOGY, publish_equivalent: BIOLOGY },
            { name: CourseSubjects::ENVIRONMENTAL_SCIENCES, publish_equivalent: BIOLOGY },
            { name: CourseSubjects::GENERAL_SCIENCES, publish_equivalent: BIOLOGY },
          ],
        },
        BUSINESS_STUDIES => {
          entity_id: "b3f10516-aac2-e611-80be-00155d010316",
          subject_specialisms: [
            { name: CourseSubjects::BUSINESS_MANAGEMENT, publish_equivalent: BUSINESS_STUDIES },
            { name: CourseSubjects::BUSINESS_STUDIES, publish_equivalent: BUSINESS_STUDIES },
            { name: CourseSubjects::RECREATION_AND_LEISURE_STUDIES, publish_equivalent: BUSINESS_STUDIES },
            { name: CourseSubjects::RETAIL_MANAGEMENT, publish_equivalent: BUSINESS_STUDIES },
          ],
        },
        CHEMISTRY => {
          entity_id: "b5f10516-aac2-e611-80be-00155d010316",
          subject_specialisms: [
            { name: CourseSubjects::APPLIED_CHEMISTRY, publish_equivalent: CHEMISTRY },
            { name: CourseSubjects::CHEMISTRY, publish_equivalent: CHEMISTRY },
          ],
        },
        CLASSICS => {
          entity_id: "b9f10516-aac2-e611-80be-00155d010316",
          subject_specialisms: [
            { name: CourseSubjects::ANCIENT_HEBREW, publish_equivalent: CLASSICS },
            { name: CourseSubjects::CLASSICAL_GREEK_STUDIES, publish_equivalent: CLASSICS },
            { name: CourseSubjects::CLASSICAL_STUDIES, publish_equivalent: CLASSICS },
            { name: CourseSubjects::HISTORICAL_LINGUISTICS, publish_equivalent: CLASSICS },
            { name: CourseSubjects::LATIN_LANGUAGE, publish_equivalent: CLASSICS },
          ],
        },
        COMPUTING => {
          entity_id: "bdf10516-aac2-e611-80be-00155d010316",
          subject_specialisms: [
            { name: CourseSubjects::APPLIED_COMPUTING, publish_equivalent: COMPUTING },
            { name: CourseSubjects::COMPUTER_SCIENCE, publish_equivalent: COMPUTING },
            { name: CourseSubjects::INFORMATION_TECHNOLOGY, publish_equivalent: COMPUTING },
          ],
        },
        DESIGN_AND_TECHNOLOGY => {
          entity_id: "c1f10516-aac2-e611-80be-00155d010316",
          subject_specialisms: [
            { name: CourseSubjects::CONSTRUCTION_AND_THE_BUILT_ENVIRONMENT, publish_equivalent: DESIGN_AND_TECHNOLOGY },
            { name: CourseSubjects::DESIGN, publish_equivalent: DESIGN_AND_TECHNOLOGY },
            { name: CourseSubjects::FOOD_AND_BEVERAGE_STUDIES, publish_equivalent: DESIGN_AND_TECHNOLOGY },
            { name: CourseSubjects::GENERAL_OR_INTEGRATED_ENGINEERING, publish_equivalent: DESIGN_AND_TECHNOLOGY },
            { name: CourseSubjects::HOSPITALITY, publish_equivalent: DESIGN_AND_TECHNOLOGY },
            { name: CourseSubjects::MANUFACTURING_ENGINEERING, publish_equivalent: DESIGN_AND_TECHNOLOGY },
            { name: CourseSubjects::MATERIALS_SCIENCE, publish_equivalent: DESIGN_AND_TECHNOLOGY },
            { name: CourseSubjects::PRODUCTION_AND_MANUFACTURING_ENGINEERING, publish_equivalent: DESIGN_AND_TECHNOLOGY },
            { name: CourseSubjects::PRODUCT_DESIGN, publish_equivalent: DESIGN_AND_TECHNOLOGY },
            { name: CourseSubjects::TEXTILES_TECHNOLOGY, publish_equivalent: DESIGN_AND_TECHNOLOGY },
          ],
        },
        DRAMA => {
          entity_id: "c3f10516-aac2-e611-80be-00155d010316",
          subject_specialisms: [
            { name: CourseSubjects::DRAMA, publish_equivalent: DRAMA },
            { name: CourseSubjects::PERFORMING_ARTS, publish_equivalent: DRAMA },
          ],
        },
        EARLY_YEARS_ITT => {
          entity_id: "fbf10516-aac2-e611-80be-00155d010316",
          subject_specialisms: [
            { name: CourseSubjects::EARLY_YEARS_TEACHING, publish_equivalent: nil },
          ],
        },
        ECONOMICS => {
          entity_id: "c5f10516-aac2-e611-80be-00155d010316",
          subject_specialisms: [
            { name: CourseSubjects::ECONOMICS, publish_equivalent: ECONOMICS },
          ],
        },
        ENGLISH => {
          entity_id: "c9f10516-aac2-e611-80be-00155d010316",
          subject_specialisms: [
            { name: CourseSubjects::ENGLISH_STUDIES, publish_equivalent: ENGLISH },
          ],
        },
        GEOGRAPHY => {
          entity_id: "cbf10516-aac2-e611-80be-00155d010316",
          subject_specialisms: [
            { name: CourseSubjects::GEOGRAPHY, publish_equivalent: GEOGRAPHY },
          ],
        },
        HISTORY => {
          entity_id: "cff10516-aac2-e611-80be-00155d010316",
          subject_specialisms: [
            { name: CourseSubjects::HISTORY, publish_equivalent: HISTORY },
          ],
        },
        MATHEMATICS => {
          entity_id: "d7f10516-aac2-e611-80be-00155d010316",
          subject_specialisms: [
            { name: CourseSubjects::MATHEMATICS, publish_equivalent: MATHEMATICS },
            { name: CourseSubjects::STATISTICS, publish_equivalent: MATHEMATICS },
          ],
        },
        MODERN_LANGUAGES => {
          entity_id: "dbf10516-aac2-e611-80be-00155d010316",
          subject_specialisms: [
            { name: CourseSubjects::MODERN_LANGUAGES, publish_equivalent: "Modern languages (other)" },
            { name: CourseSubjects::ARABIC_LANGUAGES, publish_equivalent: "Modern languages (other)" },
            { name: CourseSubjects::CHINESE_LANGUAGES, publish_equivalent: "Mandarin" },
            { name: CourseSubjects::FRENCH_LANGUAGE, publish_equivalent: "French" },
            { name: CourseSubjects::GERMAN_LANGUAGE, publish_equivalent: "German" },
            { name: CourseSubjects::ITALIAN_LANGUAGE, publish_equivalent: "Italian" },
            { name: CourseSubjects::PORTUGUESE_LANGUAGE, publish_equivalent: "Modern languages (other)" },
            { name: CourseSubjects::RUSSIAN_LANGUAGES, publish_equivalent: "Russian" },
            { name: CourseSubjects::SPANISH_LANGUAGE, publish_equivalent: "Spanish" },
            { name: CourseSubjects::WELSH_LANGUAGE, publish_equivalent: "Modern languages (other)" },
          ],
        },
        MUSIC => {
          entity_id: "ddf10516-aac2-e611-80be-00155d010316",
          subject_specialisms: [
            { name: CourseSubjects::MUSIC_EDUCATION_AND_TEACHING, publish_equivalent: MUSIC },
          ],
        },
        OTHER_SUBJECTS => {
          entity_id: "dff10516-aac2-e611-80be-00155d010316",
          subject_specialisms: [
            { name: CourseSubjects::CHILD_DEVELOPMENT, publish_equivalent: nil },
            { name: CourseSubjects::HAIR_AND_BEAUTY_SCIENCES, publish_equivalent: nil },
            { name: CourseSubjects::HEALTH_AND_SOCIAL_CARE, publish_equivalent: "Health and social care" },
            { name: CourseSubjects::HEALTH_STUDIES, publish_equivalent: nil },
            { name: CourseSubjects::LAW, publish_equivalent: nil },
            { name: CourseSubjects::MEDIA_AND_COMMUNICATION_STUDIES, publish_equivalent: "Communication and media studies" },
            { name: CourseSubjects::PSYCHOLOGY, publish_equivalent: "Psychology" },
            { name: CourseSubjects::PUBLIC_SERVICES, publish_equivalent: nil },
            { name: CourseSubjects::SOCIAL_SCIENCES, publish_equivalent: "Social sciences" },
            { name: CourseSubjects::TRAVEL_AND_TOURISM, publish_equivalent: nil },
            { name: CourseSubjects::UK_GOVERNMENT_PARLIAMENTARY_STUDIES, publish_equivalent: "Citizenship" },
          ],
        },
        PHYSICAL_EDUCATION => {
          entity_id: "e3f10516-aac2-e611-80be-00155d010316",
          subject_specialisms: [
            { name: CourseSubjects::DANCE, publish_equivalent: "Dance" },
            { name: CourseSubjects::SPORTS_MANAGEMENT, publish_equivalent: PHYSICAL_EDUCATION },
            { name: CourseSubjects::SPORT_AND_EXERCISE_SCIENCES, publish_equivalent: PHYSICAL_EDUCATION },
          ],
        },
        RELIGIOUS_EDUCATION => {
          entity_id: "f7f10516-aac2-e611-80be-00155d010316",
          subject_specialisms: [
            { name: CourseSubjects::PHILOSOPHY, publish_equivalent: "Philosophy" },
            { name: CourseSubjects::RELIGIOUS_STUDIES, publish_equivalent: "Religious education" },
          ],
        },
        PHYSICS => {
          entity_id: "e5f10516-aac2-e611-80be-00155d010316",
          subject_specialisms: [
            { name: CourseSubjects::APPLIED_PHYSICS, publish_equivalent: PHYSICS },
            { name: CourseSubjects::PHYSICS, publish_equivalent: PHYSICS },
          ],
        },
        PRIMARY => {
          entity_id: "e9f10516-aac2-e611-80be-00155d010316",
          subject_specialisms: [
            { name: CourseSubjects::ENGLISH_STUDIES, publish_equivalent: "Primary with English" },
            { name: CourseSubjects::GEOGRAPHY, publish_equivalent: "Primary with geography and history" },
            { name: CourseSubjects::HISTORY, publish_equivalent: "Primary with geography and history" },
            { name: CourseSubjects::MODERN_LANGUAGES, publish_equivalent: "Primary with modern languages" },
            { name: CourseSubjects::PRIMARY_TEACHING, publish_equivalent: "English as a second or other language" },
            { name: CourseSubjects::PRIMARY_TEACHING, publish_equivalent: "Primary with geography and history" },
            { name: CourseSubjects::PRIMARY_TEACHING, publish_equivalent: "Primary with modern languages" },
            { name: CourseSubjects::PRIMARY_TEACHING, publish_equivalent: "Primary with physical education" },
            { name: CourseSubjects::PRIMARY_TEACHING, publish_equivalent: "Primary with science" },
            { name: CourseSubjects::PRIMARY_TEACHING, publish_equivalent: PRIMARY },
            { name: CourseSubjects::SCIENCE, publish_equivalent: "Primary with science" },
            { name: CourseSubjects::SPECIALIST_TEACHING_PRIMARY_WITH_MATHEMETICS, publish_equivalent: PRIMARY_WITH_MATHEMATICS },
            { name: CourseSubjects::SPORTS_MANAGEMENT, publish_equivalent: "Primary with physical education" },
            { name: CourseSubjects::SPORT_AND_EXERCISE_SCIENCES, publish_equivalent: "Primary with physical education" },
          ],
        },
      }.freeze
    end
  end
end
