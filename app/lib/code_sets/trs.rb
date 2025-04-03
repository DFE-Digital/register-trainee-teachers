# frozen_string_literal: true

module CodeSets
  module Trs
    # Gender code mappings for TRS API
    GENDER_CODES = {
      male: "Male",
      female: "Female",
      other: "Other",
      prefer_not_to_say: "NotProvided",
      sex_not_provided: "NotAvailable",
    }.freeze

    # States in which trainee updates are NOT valid
    INVALID_UPDATE_STATES = %w[
      withdrawn
      awarded
    ].freeze
  end
end 