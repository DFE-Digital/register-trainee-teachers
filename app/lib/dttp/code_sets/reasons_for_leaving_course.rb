# frozen_string_literal: true

module Dttp
  module CodeSets
    module ReasonsForLeavingCourse
      MAPPING = {
        WithdrawalReasons::DEATH => { entity_id: "4d6a46ad-11c2-e611-80be-00155d010316" },
        WithdrawalReasons::EXCLUSION => { entity_id: "556a46ad-11c2-e611-80be-00155d010316" },
        WithdrawalReasons::FINANCIAL_REASONS => { entity_id: "4f6a46ad-11c2-e611-80be-00155d010316" },
        WithdrawalReasons::FOR_ANOTHER_REASON => { entity_id: "436a46ad-11c2-e611-80be-00155d010316" },
        WithdrawalReasons::GONE_INTO_EMPLOYMENT => { entity_id: "416a46ad-11c2-e611-80be-00155d010316" },
        WithdrawalReasons::HEALTH_REASONS => { entity_id: "4b6a46ad-11c2-e611-80be-00155d010316" },
        WithdrawalReasons::PERSONAL_REASONS => { entity_id: "516a46ad-11c2-e611-80be-00155d010316" },
        WithdrawalReasons::TRANSFERRED_TO_ANOTHER_PROVIDER => { entity_id: "496a46ad-11c2-e611-80be-00155d010316" },
        WithdrawalReasons::UNKNOWN => { entity_id: "596a46ad-11c2-e611-80be-00155d010316" },
        WithdrawalReasons::WRITTEN_OFF_AFTER_LAPSE_OF_TIME => { entity_id: "536a46ad-11c2-e611-80be-00155d010316" },
      }.freeze
    end
  end
end
