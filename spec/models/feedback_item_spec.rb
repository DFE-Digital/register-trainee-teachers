# frozen_string_literal: true

require "rails_helper"

RSpec.describe FeedbackItem do
  it do
    expect(subject).to define_enum_for(:satisfaction_level)
      .with_values({
        very_satisfied: "very_satisfied",
        satisfied: "satisfied",
        neither_satisfied_nor_dissatisfied: "neither_satisfied_nor_dissatisfied",
        dissatisfied: "dissatisfied",
        very_dissatisfied: "very_dissatisfied",
      }).backed_by_column_of_type(:string)
  end
end
