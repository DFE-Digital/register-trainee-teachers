# frozen_string_literal: true

module Dttp
  module CodeSets
    module AllocationSubjects
      MAPPING = {
        "Art and design" => { entity_id: nil, subject_specialisms: ["graphic design", "creative arts and design"] },
        "Biology" => { entity_id: nil, subject_specialisms: ["applied biology", "biology", "environmental sciences", "general sciences"] },
        "Business studies" => { entity_id: nil, subject_specialisms: ["business and management", "business studies", "retail management", "recreation and leisure studies"] },
        "Chemistry" => { entity_id: nil, subject_specialisms: ["chemistry", "applied chemistry"] },
        "Other subjects" => { entity_id: nil, subject_specialisms: ["UK government / Parliamentary studies", "media and communication studies", "health and social care", "psychology", "social sciences", "public services", "travel and tourism", "child development", "health studies", "law", "hair and beauty sciences"] },
        "Classics" => { entity_id: nil, subject_specialisms: ["Ancient Hebrew", "classical studies", "classical Greek studies", "historical linguistics", "Latin language"] },
        "Computing" => { entity_id: nil, subject_specialisms: ["applied computing", "computer science", "information technology"] },
        "Physical education" => { entity_id: nil, subject_specialisms: ["dance", "sports management", "sport and exercise sciences"] },
        "Design and technology" => { entity_id: nil, subject_specialisms: ["design", "product design", "construction and the built environment", "general or integrated engineering", "manufacturing engineering", "production and manufacturing engineering", "textiles technology", "materials science", "food and beverage studies", "hospitality"] },
        "Drama" => { entity_id: nil, subject_specialisms: ["drama", "performing arts"] },
        "Economics" => { entity_id: nil, subject_specialisms: %w[economics] },
        "English" => { entity_id: nil, subject_specialisms: ["English studies"] },
        "Modern languages" => { entity_id: nil, subject_specialisms: ["French language", "German language", "Italian language", "modern languages", "Chinese languages", "Arabic languages", "Welsh language", "Portuguese language", "Russian languages", "Spanish language"] },
        "Geography" => { entity_id: nil, subject_specialisms: %w[geography] },
        "History" => { entity_id: nil, subject_specialisms: %w[history] },
        "Mathematics" => { entity_id: nil, subject_specialisms: %w[mathematics statistics] },
        "Music" => { entity_id: nil, subject_specialisms: ["music education and teaching"] },
        "Religious education" => { entity_id: nil, subject_specialisms: ["philosophy", "religious studies"] },
        "Physics" => { entity_id: nil, subject_specialisms: ["physics", "applied physics"] },
        "Primary" => { entity_id: nil, subject_specialisms: ["primary teaching"] },
        "Early years ITT" => { entity_id: nil, subject_specialisms: ["early years teaching"] },
        "Primary with mathematics" => { entity_id: nil, subject_specialisms: ["specialist teaching (primary with mathematics)"] },
      }.freeze
    end
  end
end
