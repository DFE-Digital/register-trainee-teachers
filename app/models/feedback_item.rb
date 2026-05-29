# frozen_string_literal: true

# == Schema Information
#
# Table name: feedback_items
#
#  id                     :bigint           not null, primary key
#  email                  :string
#  improvement_suggestion :string           not null
#  name                   :string
#  satisfaction_level     :string           not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
class FeedbackItem < ApplicationRecord
  enum :satisfaction_level, {
    very_satisfied: "very_satisfied",
    satisfied: "satisfied",
    neither_satisfied_nor_dissatisfied: "neither_satisfied_nor_dissatisfied",
    dissatisfied: "dissatisfied",
    very_dissatisfied: "very_dissatisfied",
  }
end
