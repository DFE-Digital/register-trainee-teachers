# frozen_string_literal: true

module Dttp
  module CodeSets
    module AgeRanges
      MAPPING = {
        AgeRange::THREE_TO_SEVEN => { entity_id: "b86eee51-8ec0-e611-80be-00155d010316", option: :main, levels: [:primary] },
        AgeRange::THREE_TO_ELEVEN => { entity_id: "efa15e61-8ec0-e611-80be-00155d010316", option: :main, levels: [:primary] },
        AgeRange::FIVE_TO_ELEVEN => { entity_id: "22215c74-8ec0-e611-80be-00155d010316", option: :main, levels: [:primary] },
        AgeRange::ELEVEN_TO_SIXTEEN => { entity_id: "feed86a2-8ec0-e611-80be-00155d010316", option: :main, levels: [:secondary] },
        AgeRange::ELEVEN_TO_EIGHTEEN => { entity_id: "50abf56b-9e35-ec11-8c64-000d3ab973d7", option: :main, levels: [:secondary] },

        # These appear in 'other' dropdown:
        AgeRange::ZERO_TO_FIVE => { entity_id: "4660ff36-3c6d-e711-80d2-005056ac45bb", option: :additional },
        AgeRange::TWO_TO_SEVEN => { entity_id: "c938d632-9d35-ec11-8c64-000d3ab973d7", option: :additional, levels: [:primary] },
        AgeRange::TWO_TO_ELEVEN => { entity_id: "d22ae77a-9d35-ec11-8c64-000d3ab973d7", option: :additional, levels: [:primary] },
        AgeRange::TWO_TO_NINETEEN => { entity_id: "532627b1-9d35-ec11-8c64-000d3ab973d7", option: :additional, levels: [:secondary] },
        AgeRange::THREE_TO_EIGHT => { entity_id: "49a9eb3f-5a9c-e711-80d9-005056ac45bb", option: :additional, levels: [:primary] },
        AgeRange::THREE_TO_NINE => { entity_id: "eea15e61-8ec0-e611-80be-00155d010316", option: :additional, levels: [:primary] },
        AgeRange::THREE_TO_SIXTEEN => { entity_id: "fb8898d5-9d35-ec11-8c64-000d3ab973d7", option: :additional, levels: [:secondary] },
        AgeRange::FOUR_TO_ELEVEN => { entity_id: "e3d8b2ed-9d35-ec11-8c64-000d3ab973d7", option: :additional, levels: [:primary] },
        AgeRange::FOUR_TO_NINETEEN => { entity_id: "f70bbdff-9d35-ec11-8c64-000d3ab973d7", option: :additional, levels: [:secondary] },
        AgeRange::FIVE_TO_NINE => { entity_id: "21215c74-8ec0-e611-80be-00155d010316", option: :additional, levels: [:primary] },
        AgeRange::FIVE_TO_FOURTEEN => { entity_id: "187ee9f5-569c-e711-80d9-005056ac45bb", option: :additional, levels: [:secondary] },
        AgeRange::FIVE_TO_EIGHTEEN => { entity_id: "eb8edb1d-9e35-ec11-8c64-000d3ab973d7", option: :additional, levels: [:secondary] },
        AgeRange::SEVEN_TO_ELEVEN => { entity_id: "fad38a88-8ec0-e611-80be-00155d010316", option: :additional, levels: %i[primary] },
        AgeRange::SEVEN_TO_FOURTEEN => { entity_id: "fbd38a88-8ec0-e611-80be-00155d010316", option: :additional, levels: [:secondary] },
        AgeRange::SEVEN_TO_SIXTEEN => { entity_id: "1a7ee9f5-569c-e711-80d9-005056ac45bb", option: :additional, levels: [:secondary] },
        AgeRange::SEVEN_TO_EIGHTEEN => { entity_id: "2cc7ee35-9e35-ec11-8c64-000d3ab973d7", option: :additional, levels: [:secondary] },
        AgeRange::NINE_TO_THIRTEEN => { entity_id: "78b5fc53-9e35-ec11-8c64-000d3ab973d7", option: :additional, levels: [:secondary] },
        AgeRange::NINE_TO_FOURTEEN => { entity_id: "7064d397-8ec0-e611-80be-00155d010316", option: :additional, levels: [:secondary] },
        AgeRange::NINE_TO_SIXTEEN => { entity_id: "1c7ee9f5-569c-e711-80d9-005056ac45bb", option: :additional, levels: [:secondary] },
        AgeRange::ELEVEN_TO_NINETEEN => { entity_id: "69e663ac-8ec0-e611-80be-00155d010316", option: :additional, levels: [:secondary] },
        AgeRange::THIRTEEN_TO_EIGHTEEN => { entity_id: "d2abf17d-9e35-ec11-8c64-000d3ab973d7", option: :additional, levels: [:secondary] },
        AgeRange::FOURTEEN_TO_EIGHTEEN => { entity_id: "01b0fa9b-9e35-ec11-8c64-000d3ab973d7", option: :additional, levels: [:secondary] },
        AgeRange::FOURTEEN_TO_NINETEEN => { entity_id: "73a86fb7-8ec0-e611-80be-00155d010316", option: :additional, levels: [:secondary] },
      }.freeze
    end
  end
end
