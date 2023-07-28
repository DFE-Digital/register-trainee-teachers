# frozen_string_literal: true

module Trainees
  class MapStateFromHesa
    include ServicePattern

    def initialize(hesa_trainee:, trainee:)
      @hesa_trainee = hesa_trainee
      @trainee = trainee
    end

    def call
      return :awarded if trainee.awarded?
      return :deferred if trainee_dormant?

      trainee.trn.present? ? :trn_received : :submitted_for_trn
    end

  private

    attr_reader :hesa_trainee, :trainee

    def trainee_dormant?
      [
        ::Hesa::CodeSets::Modes::DORMANT_FULL_TIME,
        ::Hesa::CodeSets::Modes::DORMANT_PART_TIME,
      ].include?(mode)
    end

    def mode
      ::Hesa::CodeSets::Modes::MAPPING[hesa_trainee[:mode]]
    end
  end
end
