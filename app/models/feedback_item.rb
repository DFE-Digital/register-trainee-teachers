# frozen_string_literal: true

class FeedbackItem < ApplicationRecord
  enum :satisfaction_level, {
    very_satisfied: "very_satisfied",
    satisfied: "satisfied",
    neither_satisfied_nor_dissatisfied: "neither_satisfied_nor_dissatisfied",
    dissatisfied: "dissatisfied",
    very_dissatisfied: "very_dissatisfied",
  }
end
