# frozen_string_literal: true

module Dttp
  module CodeSets
    module AgeRanges
      THREE_TO_SEVEN = "b86eee51-8ec0-e611-80be-00155d010316"
      THREE_TO_ELEVEN = "efa15e61-8ec0-e611-80be-00155d010316"
      ELEVEN_TO_NINETEEN = "69e663ac-8ec0-e611-80be-00155d010316"
      FOURTEEN_TO_NINETEEN = "73a86fb7-8ec0-e611-80be-00155d010316"
      SEVEN_TO_SIXTEEN = "1a7ee9f5-569c-e711-80d9-005056ac45bb"
      FIVE_TO_ELEVEN = "22215c74-8ec0-e611-80be-00155d010316"
      FIVE_TO_FOURTEEN = "187ee9f5-569c-e711-80d9-005056ac45bb"
      NINE_TO_FOURTEEN = "7064d397-8ec0-e611-80be-00155d010316"

      MAPPING = {
        AgeRange::ZERO_TO_FIVE => { entity_id: "4660ff36-3c6d-e711-80d2-005056ac45bb", option: :additional },

        AgeRange::THREE_TO_SEVEN => { entity_id: THREE_TO_SEVEN, option: :main, levels: [:primary] },
        AgeRange::THREE_TO_ELEVEN => { entity_id: THREE_TO_ELEVEN, option: :main, levels: [:primary] },
        AgeRange::FIVE_TO_ELEVEN => { entity_id: FIVE_TO_ELEVEN, option: :main, levels: [:primary] },

        AgeRange::ELEVEN_TO_SIXTEEN => { entity_id: "feed86a2-8ec0-e611-80be-00155d010316", option: :main, levels: [:secondary] },

        AgeRange::ELEVEN_TO_EIGHTEEN => { entity_id: ELEVEN_TO_NINETEEN, option: :main, levels: [:secondary] }, # this is currently mapped to 11-19 in DTTP as there isn't an option for 11-18 yet.

        # These appear in 'other' dropdown:
        AgeRange::TWO_TO_SEVEN => { entity_id: THREE_TO_SEVEN, option: :additional, levels: [:primary] }, # currently mapped to 3-7 in DTTP
        AgeRange::TWO_TO_ELEVEN => { entity_id: THREE_TO_ELEVEN, option: :additional, levels: [:primary] }, # currently mapped to 3-11 in DTTP
        AgeRange::TWO_TO_NINETEEN => { entity_id: ELEVEN_TO_NINETEEN, option: :additional, levels: [:secondary] }, # currently mapped to 11-19 in DTTP
        AgeRange::THREE_TO_EIGHT => { entity_id: "49a9eb3f-5a9c-e711-80d9-005056ac45bb", option: :additional, levels: [:primary] },
        AgeRange::THREE_TO_NINE => { entity_id: "eea15e61-8ec0-e611-80be-00155d010316", option: :additional, levels: [:primary] },
        AgeRange::THREE_TO_SIXTEEN => { entity_id: SEVEN_TO_SIXTEEN, option: :additional, levels: [:secondary] }, # currently mapped to 7-16 in DTTP
        AgeRange::FOUR_TO_ELEVEN => { entity_id: FIVE_TO_ELEVEN, option: :additional, levels: [:primary] }, # currently mapped to 5-11 in DTTP
        AgeRange::FOUR_TO_NINETEEN => { entity_id: ELEVEN_TO_NINETEEN, option: :additional, levels: [:secondary] }, # currently mapped to 11-19 in DTTP
        AgeRange::FIVE_TO_NINE => { entity_id: "21215c74-8ec0-e611-80be-00155d010316", option: :additional, levels: [:primary] },
        AgeRange::FIVE_TO_FOURTEEN => { entity_id: FIVE_TO_FOURTEEN, option: :additional, levels: [:secondary] },
        AgeRange::FIVE_TO_EIGHTEEN => { entity_id: FIVE_TO_FOURTEEN, option: :additional, levels: [:secondary] }, # currently mapped to 5-14 in DTTP
        AgeRange::SEVEN_TO_ELEVEN => { entity_id: "fad38a88-8ec0-e611-80be-00155d010316", option: :additional, levels: %i[primary secondary] },
        AgeRange::SEVEN_TO_FOURTEEN => { entity_id: "fbd38a88-8ec0-e611-80be-00155d010316", option: :additional, levels: [:secondary] },
        AgeRange::SEVEN_TO_SIXTEEN => { entity_id: SEVEN_TO_SIXTEEN, option: :additional, levels: [:secondary] },
        AgeRange::SEVEN_TO_EIGHTEEN => { entity_id: SEVEN_TO_SIXTEEN, option: :additional, levels: [:secondary] }, # currently mapped to 7-16 in DTTP
        AgeRange::NINE_TO_THIRTEEN => { entity_id: NINE_TO_FOURTEEN, option: :additional, levels: [:secondary] }, # currently mapped to 9-14 in DTTP
        AgeRange::NINE_TO_FOURTEEN => { entity_id: NINE_TO_FOURTEEN, option: :additional, levels: [:secondary] },
        AgeRange::NINE_TO_SIXTEEN => { entity_id: "1c7ee9f5-569c-e711-80d9-005056ac45bb", option: :additional, levels: [:secondary] },
        AgeRange::ELEVEN_TO_NINETEEN => { entity_id: ELEVEN_TO_NINETEEN, option: :additional, levels: [:secondary] },
        AgeRange::THIRTEEN_TO_EIGHTEEN => { entity_id: FOURTEEN_TO_NINETEEN, option: :additional, levels: [:secondary] }, # currently mapped to 14-19 in DTTP
        AgeRange::FOURTEEN_TO_EIGHTEEN => { entity_id: FOURTEEN_TO_NINETEEN, option: :additional, levels: [:secondary] }, # currently mapped to 14-19 in DTTP
        AgeRange::FOURTEEN_TO_NINETEEN => { entity_id: FOURTEEN_TO_NINETEEN, option: :additional, levels: [:secondary] },
      }.freeze
    end
  end
end
