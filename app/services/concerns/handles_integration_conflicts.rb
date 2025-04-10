# frozen_string_literal: true

module HandlesIntegrationConflicts
  extend ActiveSupport::Concern

  # Single, clear error class to use across all services
  class ConflictingIntegrationsError < StandardError
    def message
      "Both DQT and TRS integrations are enabled. Only one should be active at a time."
    end
  end

  # Checks if both DQT and TRS integrations are enabled
  # Can be conditionally checked by passing a block
  # Example: check_for_conflicting_integrations { update_dqt }
  def check_for_conflicting_integrations
    # If a block is given, only check for conflicts if the block returns true
    should_check = block_given? ? yield : true
    
    if should_check && dqt_enabled && trs_enabled
      raise ConflictingIntegrationsError
    end
  end
end 