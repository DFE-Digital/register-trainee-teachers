# frozen_string_literal: true

module Dttp
  module CodeSets
    module Statuses
      MAPPING = {
        DttpStatuses::AWAITING_QTS => { entity_id: "1b5af972-9e1b-e711-80c7-0050568902d3" },
        DttpStatuses::AWARDED_EYTS => { entity_id: "2d5af972-9e1b-e711-80c7-0050568902d3" },
        DttpStatuses::AWARDED_QTS => { entity_id: "195af972-9e1b-e711-80c7-0050568902d3" },
        DttpStatuses::DRAFT_RECORD => { entity_id: "2b5af972-9e1b-e711-80c7-0050568902d3" },
        DttpStatuses::EYTS_REVOKED => { entity_id: "2f5af972-9e1b-e711-80c7-0050568902d3" },
        DttpStatuses::LEFT_COURSE_BEFORE_END => { entity_id: "235af972-9e1b-e711-80c7-0050568902d3" },
        DttpStatuses::PROSPECTIVE_TRAINEE_TRN_REQUESTED => { entity_id: "275af972-9e1b-e711-80c7-0050568902d3" },
        DttpStatuses::QTS_REVOKED => { entity_id: "155af972-9e1b-e711-80c7-0050568902d3" },
        DttpStatuses::STANDARDS_MET => { entity_id: "1f5af972-9e1b-e711-80c7-0050568902d3" },
        DttpStatuses::STANDARDS_NOT_MET => { entity_id: "215af972-9e1b-e711-80c7-0050568902d3" },
        DttpStatuses::DEFERRED => { entity_id: "1d5af972-9e1b-e711-80c7-0050568902d3" },
        DttpStatuses::DID_NOT_START => { entity_id: "255af972-9e1b-e711-80c7-0050568902d3" },
        DttpStatuses::REJECTED => { entity_id: "175af972-9e1b-e711-80c7-0050568902d3" },
        DttpStatuses::YET_TO_COMPLETE_COURSE => { entity_id: "295af972-9e1b-e711-80c7-0050568902d3" },
      }.freeze
    end
  end
end
