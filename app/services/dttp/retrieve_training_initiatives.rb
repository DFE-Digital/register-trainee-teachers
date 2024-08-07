# frozen_string_literal: true

module Dttp
  class RetrieveTrainingInitiatives
    include ServicePattern
    include SyncPattern

  private

    def default_path
      @default_path ||= "/dfe_initiatives"
    end
  end
end
