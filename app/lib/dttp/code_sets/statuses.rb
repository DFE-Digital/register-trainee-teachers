# frozen_string_literal: true

module Dttp
  module CodeSets
    module Statuses
      MAPPING = {
        "Awaiting QTS" => { entity_id: "1b5af972-9e1b-e711-80c7-0050568902d3" },
        "Awarded EYTS" => { entity_id: "2d5af972-9e1b-e711-80c7-0050568902d3" },
        "Awarded QTS" => { entity_id: "195af972-9e1b-e711-80c7-0050568902d3" },
        "Draft record" => { entity_id: "2b5af972-9e1b-e711-80c7-0050568902d3" },
        "EYTS Revoked" => { entity_id: "2f5af972-9e1b-e711-80c7-0050568902d3" },
        "Left course before the end" => { entity_id: "235af972-9e1b-e711-80c7-0050568902d3" },
        "Prospective trainee - TREFNO requested" => { entity_id: "275af972-9e1b-e711-80c7-0050568902d3" },
        "QTS revoked" => { entity_id: "155af972-9e1b-e711-80c7-0050568902d3" },
        "Standards met" => { entity_id: "1f5af972-9e1b-e711-80c7-0050568902d3" },
        "Standards not met" => { entity_id: "215af972-9e1b-e711-80c7-0050568902d3" },
        "Trainee deferred" => { entity_id: "1d5af972-9e1b-e711-80c7-0050568902d3" },
        "Trainee did not start course" => { entity_id: "255af972-9e1b-e711-80c7-0050568902d3" },
        "Trainee rejected/revoked from ITT Studies" => { entity_id: "175af972-9e1b-e711-80c7-0050568902d3" },
        "Yet to complete the course" => { entity_id: "295af972-9e1b-e711-80c7-0050568902d3" },
      }.freeze
    end
  end
end
