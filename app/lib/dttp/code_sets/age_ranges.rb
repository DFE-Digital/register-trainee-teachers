# frozen_string_literal: true

module Dttp
  module CodeSets
    module AgeRanges
      MAPPING = {
        AgeRange::THREE_TO_ELEVEN_COURSE => { option: :main, entity_id: "efa15e61-8ec0-e611-80be-00155d010316" },
        AgeRange::FIVE_TO_ELEVEN_COURSE => { option: :main, entity_id: "22215c74-8ec0-e611-80be-00155d010316" },
        AgeRange::ELEVEN_TO_SIXTEEN_COURSE => { option: :main, entity_id: "feed86a2-8ec0-e611-80be-00155d010316" },
        AgeRange::ELEVEN_TO_NINETEEN_COURSE => { option: :main, entity_id: "69e663ac-8ec0-e611-80be-00155d010316" },
        AgeRange::ZERO_TO_FIVE_COURSE => { option: :additional, entity_id: "eea15e61-8ec0-e611-80be-00155d010316" },
        AgeRange::THREE_TO_SEVEN_COURSE => { option: :additional, entity_id: "4660ff36-3c6d-e711-80d2-005056ac45bb" },
        AgeRange::THREE_TO_EIGHT_COURSE => { option: :additional, entity_id: "b86eee51-8ec0-e611-80be-00155d010316" },
        AgeRange::THREE_TO_NINE_COURSE => { option: :additional, entity_id: "8531bb82-2f71-e811-80f3-005056ac45bb" },
        AgeRange::FIVE_TO_NINE_COURSE => { option: :additional, entity_id: "21215c74-8ec0-e611-80be-00155d010316" },
        AgeRange::FIVE_TO_FOURTEEN_COURSE => { option: :additional, entity_id: "187ee9f5-569c-e711-80d9-005056ac45bb" },
        AgeRange::SEVEN_TO_ELEVEN_COURSE => { option: :additional, entity_id: "fad38a88-8ec0-e611-80be-00155d010316" },
        AgeRange::SEVEN_TO_FOURTEEN_COURSE => { option: :additional, entity_id: "fbd38a88-8ec0-e611-80be-00155d010316" },
        AgeRange::SEVEN_TO_SIXTEEN_COURSE => { option: :additional, entity_id: "1a7ee9f5-569c-e711-80d9-005056ac45bb" },
        AgeRange::NINE_TO_FOURTEEN_COURSE => { option: :additional, entity_id: "7064d397-8ec0-e611-80be-00155d010316" },
        AgeRange::NINE_TO_SIXTEEN_COURSE => { option: :additional, entity_id: "1c7ee9f5-569c-e711-80d9-005056ac45bb" },
        AgeRange::FOURTEEN_TO_NINETEEN_COURSE => { option: :additional, entity_id: "73a86fb7-8ec0-e611-80be-00155d010316" },
        AgeRange::FOURTEEN_TO_NINETEEN_DIPLOMA => { option: :additional, entity_id: "41a9eb3f-5a9c-e711-80d9-005056ac45bb" },
      }.freeze
    end
  end
end
