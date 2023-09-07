# frozen_string_literal: true

module Dttp
  module CodeSets
    module CourseSubjects
      EARLY_YEARS_DTTP_ID = "3aa12838-b3cf-e911-a860-000d3ab1da01"
      MODERN_LANGUAGES_DTTP_ID = "6ca12838-b3cf-e911-a860-000d3ab1da01"

      MAPPING = {
        ::CourseSubjects::ANCIENT_HEBREW => { entity_id: "5fcd03f1-83ef-eb11-bacb-000d3ab62e3c" },
        ::CourseSubjects::APPLIED_BIOLOGY => { entity_id: "11a12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::APPLIED_CHEMISTRY => { entity_id: "1ca12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::APPLIED_COMPUTING => { entity_id: "1ea12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::APPLIED_PHYSICS => { entity_id: "20a12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::ARABIC_LANGUAGES => { entity_id: "b7f49dcd-aaeb-eb11-bacb-0022489ad2a6" },
        ::CourseSubjects::ART_AND_DESIGN => { entity_id: "32a12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::BIOLOGY => { entity_id: "22a12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::BUSINESS_MANAGEMENT => { entity_id: "24a12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::BUSINESS_STUDIES => { entity_id: "26a12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::CHEMISTRY => { entity_id: "28a12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::CHILD_DEVELOPMENT => { entity_id: EARLY_YEARS_DTTP_ID },
        ::CourseSubjects::CHINESE_LANGUAGES => { entity_id: "b5af6d41-f103-eb11-a813-000d3ab1d47c" },
        ::CourseSubjects::CITIZENSHIP => { entity_id: "3b1724c0-e5ee-eb11-bacb-000d3ab62638" },
        ::CourseSubjects::CLASSICAL_GREEK_STUDIES => { entity_id: "2aa12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::CLASSICAL_STUDIES => { entity_id: "2ca12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::COMPUTER_SCIENCE => { entity_id: "2ea12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::CONSTRUCTION_AND_THE_BUILT_ENVIRONMENT => { entity_id: "30a12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::DANCE => { entity_id: "34a12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::DESIGN => { entity_id: "36a12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::DESIGN_AND_TECHNOLOGY => { entity_id: "e457b9e4-e5ee-eb11-bacb-000d3ab62638" },
        ::CourseSubjects::DRAMA => { entity_id: "38a12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::EARLY_YEARS_TEACHING => { entity_id: "3aa12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::ECONOMICS => { entity_id: "3ca12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::ENGLISH_AS_SECOND_LANGUAGE => { entity_id: "231774a1-e5ee-eb11-bacb-000d3ab62638" },
        ::CourseSubjects::ENGLISH_STUDIES => { entity_id: "3ea12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::ENVIRONMENTAL_SCIENCES => { entity_id: "40a12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::FOOD_AND_BEVERAGE_STUDIES => { entity_id: "42a12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::FRENCH_LANGUAGE => { entity_id: "44a12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::GENERAL_OR_INTEGRATED_ENGINEERING => { entity_id: "46a12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::GENERAL_SCIENCES => { entity_id: "48a12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::GEOGRAPHY => { entity_id: "4aa12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::GERMAN_LANGUAGE => { entity_id: "4ca12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::GRAPHIC_DESIGN => { entity_id: "4ea12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::HAIR_AND_BEAUTY_SCIENCES => { entity_id: "50a12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::HEALTH_AND_SOCIAL_CARE => { entity_id: "52a12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::HEALTH_STUDIES => { entity_id: "54a12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::HISTORICAL_LINGUISTICS => { entity_id: "56a12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::HISTORY => { entity_id: "58a12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::HOSPITALITY => { entity_id: "5aa12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::INFORMATION_TECHNOLOGY => { entity_id: "5ca12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::ITALIAN_LANGUAGE => { entity_id: "5ea12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::JAPANESE_LANGUAGE => { entity_id: "d8e0bcad-e5ee-eb11-bacb-000d3ab62638" },
        ::CourseSubjects::LATIN_LANGUAGE => { entity_id: "60a12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::LAW => { entity_id: "62a12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::MANUFACTURING_ENGINEERING => { entity_id: "64a12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::MATERIALS_SCIENCE => { entity_id: "66a12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::MATHEMATICS => { entity_id: "68a12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::MEDIA_AND_COMMUNICATION_STUDIES => { entity_id: "6aa12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::MODERN_LANGUAGES => { entity_id: MODERN_LANGUAGES_DTTP_ID },
        ::CourseSubjects::MUSIC_EDUCATION_AND_TEACHING => { entity_id: "6ea12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::PERFORMING_ARTS => { entity_id: "70a12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::PHILOSOPHY => { entity_id: "020fb594-a747-ec11-8c62-000d3ab8e8ce" },
        ::CourseSubjects::PHYSICAL_EDUCATION => { entity_id: "26353dcc-e5ee-eb11-bacb-000d3ab62638" },
        ::CourseSubjects::PHYSICS => { entity_id: "72a12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::PORTUGUESE_LANGUAGE => { entity_id: "74a12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::PRIMARY_TEACHING => { entity_id: "76a12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::PRODUCTION_AND_MANUFACTURING_ENGINEERING => { entity_id: "7aa12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::PRODUCT_DESIGN => { entity_id: "78a12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::PSYCHOLOGY => { entity_id: "7ca12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::PUBLIC_SERVICES => { entity_id: "7ea12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::RECREATION_AND_LEISURE_STUDIES => { entity_id: "80a12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::RELIGIOUS_STUDIES => { entity_id: "82a12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::RETAIL_MANAGEMENT => { entity_id: "84a12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::RUSSIAN_LANGUAGES => { entity_id: "86a12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::SOCIAL_SCIENCES => { entity_id: "88a12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::SPANISH_LANGUAGE => { entity_id: "8aa12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::SPORTS_MANAGEMENT => { entity_id: "90a12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::SPORT_AND_EXERCISE_SCIENCES => { entity_id: "8ea12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::STATISTICS => { entity_id: "a72916df-83ef-eb11-bacb-000d3ab62e3c" },
        ::CourseSubjects::TEXTILES_TECHNOLOGY => { entity_id: "92a12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::TRAVEL_AND_TOURISM => { entity_id: "94a12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::UK_GOVERNMENT_PARLIAMENTARY_STUDIES => { entity_id: "96a12838-b3cf-e911-a860-000d3ab1da01" },
        ::CourseSubjects::WELSH_LANGUAGE => { entity_id: "98a12838-b3cf-e911-a860-000d3ab1da01" },
      }.freeze

      INACTIVE_MAPPING = {
        ::CourseSubjects::MATHEMATICS => {
          entity_id: "768274df-181e-e711-80c8-0050568902d3",
          original_name: "Mathematics (JACS)",
        },
        ::CourseSubjects::PRIMARY_TEACHING => {
          entity_id: "f28274df-181e-e711-80c8-0050568902d3",
          original_name: "Primary (No specialism) (JACS)",
        },
        ::CourseSubjects::BIOLOGY => {
          entity_id: "568274df-181e-e711-80c8-0050568902d3",
          original_name: "Biology (JACS)",
        },
        ::CourseSubjects::EARLY_YEARS_TEACHING => {
          entity_id: "fa8274df-181e-e711-80c8-0050568902d3",
          original_name: "Primary - FS/KS1 (Early years) (JACS)",
        },
        ::CourseSubjects::CHEMISTRY => {
          entity_id: "688274df-181e-e711-80c8-0050568902d3",
          original_name: "Chemistry (JACS)",
        },
        ::CourseSubjects::PHYSICS => {
          entity_id: "6c8274df-181e-e711-80c8-0050568902d3",
          original_name: "Physics (JACS)",
        },
        ::CourseSubjects::FRENCH_LANGUAGE => {
          entity_id: "cc8274df-181e-e711-80c8-0050568902d3",
          original_name: "French (JACS)",
        },
        ::CourseSubjects::DESIGN_AND_TECHNOLOGY => {
          entity_id: "e08274df-181e-e711-80c8-0050568902d3",
          original_name: "Design and technology (JACS)",
        },
        ::CourseSubjects::COMPUTER_SCIENCE => {
          entity_id: "868274df-181e-e711-80c8-0050568902d3",
          original_name: "Computer Science (JACS)",
        },
        ::CourseSubjects::PSYCHOLOGY => {
          entity_id: "608274df-181e-e711-80c8-0050568902d3",
          original_name: "Psychology (JACS)",
        },
        ::CourseSubjects::SPANISH_LANGUAGE => {
          entity_id: "d28274df-181e-e711-80c8-0050568902d3",
          original_name: "Spanish (JACS)",
        },
        ::CourseSubjects::PHYSICAL_EDUCATION => {
          entity_id: "5c8274df-181e-e711-80c8-0050568902d3",
          original_name: "Physical education (JACS)",
        },
        ::CourseSubjects::ENGLISH_STUDIES => {
          entity_id: "c08274df-181e-e711-80c8-0050568902d",
          original_name: "English (JACS)",
        },
        ::CourseSubjects::MODERN_LANGUAGES => {
          entity_id: "d88274df-181e-e711-80c8-0050568902d3",
          original_name: "Other Modern Language (JACS)",
        },
        ::CourseSubjects::MUSIC_EDUCATION_AND_TEACHING => {
          entity_id: "e48274df-181e-e711-80c8-0050568902d3",
          original_name: "Music (JACS)",
        },
        ::CourseSubjects::DRAMA => {
          entity_id: "e88274df-181e-e711-80c8-0050568902d3",
          original_name: "Drama (JACS)",
        },
        ::CourseSubjects::GEOGRAPHY => {
          entity_id: "9c8274df-181e-e711-80c8-0050568902d3",
          original_name: "Geography (JACS)",
        },
        ::CourseSubjects::ART_AND_DESIGN => {
          entity_id: "ec8274df-181e-e711-80c8-0050568902d3",
          original_name: "Art (JACS)",
        },
        ::CourseSubjects::RELIGIOUS_STUDIES => {
          entity_id: "dc8274df-181e-e711-80c8-0050568902d3",
          original_name: "Religious education (JACS)",
        },
        ::CourseSubjects::GERMAN_LANGUAGE => {
          entity_id: "ce8274df-181e-e711-80c8-0050568902d3",
          original_name: "German (JACS)",
        },
        ::CourseSubjects::HISTORY => {
          entity_id: "da8274df-181e-e711-80c8-0050568902d3",
          original_name: "History (JACS)",
        },
        ::CourseSubjects::BUSINESS_STUDIES => {
          entity_id: "a68274df-181e-e711-80c8-0050568902d3",
          original_name: "Business studies (JACS)",
        },
        ::CourseSubjects::SOCIAL_SCIENCES => {
          entity_id: "9e8274df-181e-e711-80c8-0050568902d3",
          original_name: "Social sciences/social studies (JACS)",
        },
        ::CourseSubjects::SPORT_AND_EXERCISE_SCIENCES => {
          entity_id: "5e8274df-181e-e711-80c8-0050568902d3",
          original_name: "# Sport & exercise science not elsewhere classified for Primary PE (JACS)",
        },
        ::CourseSubjects::CLASSICAL_STUDIES => {
          entity_id: "ca8274df-181e-e711-80c8-0050568902d3",
          original_name: "Classics (JACS)",
        },
        ::CourseSubjects::CITIZENSHIP => {
          entity_id: "948274df-181e-e711-80c8-0050568902d3",
          original_name: "Citizenship (JACS)",
        },
        "Primary - General (Mathematics)" => { entity_id: "f68274df-181e-e711-80c8-0050568902d3" },
        "Primary Foundation (JACS)" => { entity_id: "f48274df-181e-e711-80c8-0050568902d3" },
        "Physics with maths (JACS)" => { entity_id: "708274df-181e-e711-80c8-0050568902d3" },
      }.freeze
    end
  end
end
