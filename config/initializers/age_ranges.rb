# frozen_string_literal: true

module AgeRange
  UPPER_BOUND_PRIMARY_AGE = 11

  MAPPING = {
    (THREE_TO_ELEVEN = [3, 11].freeze) => { entity_id: "efa15e61-8ec0-e611-80be-00155d010316", option: :main, levels: [:primary] },
    (FIVE_TO_ELEVEN = [5, 11].freeze) => { entity_id: "22215c74-8ec0-e611-80be-00155d010316", option: :main, levels: [:primary] },
    (ELEVEN_TO_SIXTEEN = [11, 16].freeze) => { entity_id: "feed86a2-8ec0-e611-80be-00155d010316", option: :main, levels: [:secondary] },
    (ELEVEN_TO_EIGHTEEN = [11, 18].freeze) => { entity_id: "50abf56b-9e35-ec11-8c64-000d3ab973d7", option: :main, levels: [:secondary] },
    (ZERO_TO_FIVE = [0, 5].freeze) => { entity_id: "4660ff36-3c6d-e711-80d2-005056ac45bb", option: :additional },
    (TWO_TO_SEVEN = [2, 7].freeze) => { entity_id: "c938d632-9d35-ec11-8c64-000d3ab973d7", option: :additional, levels: [:primary] },
    (TWO_TO_ELEVEN = [2, 11].freeze) => { entity_id: "d22ae77a-9d35-ec11-8c64-000d3ab973d7", option: :additional, levels: [:primary] },
    (TWO_TO_NINETEEN = [2, 19].freeze) => { entity_id: "532627b1-9d35-ec11-8c64-000d3ab973d7", option: :additional, levels: [:secondary] },
    (THREE_TO_SEVEN = [3, 7].freeze) => { entity_id: "b86eee51-8ec0-e611-80be-00155d010316", option: :main, levels: [:primary] },
    (THREE_TO_EIGHT = [3, 8].freeze) => { entity_id: "49a9eb3f-5a9c-e711-80d9-005056ac45bb", option: :additional, levels: [:primary] },
    (THREE_TO_NINE = [3, 9].freeze) => { entity_id: "eea15e61-8ec0-e611-80be-00155d010316", option: :additional, levels: [:primary] },
    (THREE_TO_SIXTEEN = [3, 16].freeze) => { entity_id: "fb8898d5-9d35-ec11-8c64-000d3ab973d7", option: :additional, levels: [:secondary] },
    (FOUR_TO_ELEVEN = [4, 11].freeze) => { entity_id: "e3d8b2ed-9d35-ec11-8c64-000d3ab973d7", option: :additional, levels: [:primary] },
    (FOUR_TO_NINETEEN = [4, 19].freeze) => { entity_id: "f70bbdff-9d35-ec11-8c64-000d3ab973d7", option: :additional, levels: [:secondary] },
    (FIVE_TO_NINE = [5, 9].freeze) => { entity_id: "21215c74-8ec0-e611-80be-00155d010316", option: :additional, levels: [:primary] },
    (FIVE_TO_FOURTEEN = [5, 14].freeze) => { entity_id: "187ee9f5-569c-e711-80d9-005056ac45bb", option: :additional, levels: %i[primary secondary] },
    (FIVE_TO_EIGHTEEN = [5, 18].freeze) => { entity_id: "eb8edb1d-9e35-ec11-8c64-000d3ab973d7", option: :additional, levels: [:secondary] },
    (SEVEN_TO_ELEVEN = [7, 11].freeze) => { entity_id: "fad38a88-8ec0-e611-80be-00155d010316", option: :additional, levels: [:primary] },
    (SEVEN_TO_FOURTEEN = [7, 14].freeze) => { entity_id: "fbd38a88-8ec0-e611-80be-00155d010316", option: :additional, levels: %i[primary secondary] },
    (SEVEN_TO_SIXTEEN = [7, 16].freeze) => { entity_id: "1a7ee9f5-569c-e711-80d9-005056ac45bb", option: :additional, levels: [:secondary] },
    (SEVEN_TO_EIGHTEEN = [7, 18].freeze) => { entity_id: "2cc7ee35-9e35-ec11-8c64-000d3ab973d7", option: :additional, levels: [:secondary] },
    (NINE_TO_THIRTEEN = [9, 13].freeze) => { entity_id: "1c7ee9f5-569c-e711-80d9-005056ac45bb", option: :additional, levels: [:secondary] },
    (NINE_TO_FOURTEEN = [9, 14].freeze) => { entity_id: "7064d397-8ec0-e611-80be-00155d010316", option: :additional, levels: [:secondary] },
    (NINE_TO_SIXTEEN = [9, 16].freeze) => { entity_id: "1c7ee9f5-569c-e711-80d9-005056ac45bb", option: :additional, levels: [:secondary] },
    (ELEVEN_TO_NINETEEN = [11, 19].freeze) => { entity_id: "69e663ac-8ec0-e611-80be-00155d010316", option: :additional, levels: [:secondary] },
    (THIRTEEN_TO_EIGHTEEN = [13, 18].freeze) => { entity_id: "d2abf17d-9e35-ec11-8c64-000d3ab973d7", option: :additional, levels: [:secondary] },
    (FOURTEEN_TO_EIGHTEEN = [14, 18].freeze) => { entity_id: "01b0fa9b-9e35-ec11-8c64-000d3ab973d7", option: :additional, levels: [:secondary] },
    (FOURTEEN_TO_NINETEEN = [14, 19].freeze) => { entity_id: "73a86fb7-8ec0-e611-80be-00155d010316", option: :additional, levels: [:secondary] },
  }.freeze
end
