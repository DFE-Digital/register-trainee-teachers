# frozen_string_literal: true

module Dttp
  class RetrieveDegreeQualifications
    include ServicePattern
    include SyncPattern

  private

    def default_path
      @default_path ||= "/dfe_degreequalifications"
    end
  end
end
