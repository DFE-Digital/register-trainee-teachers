# frozen_string_literal: true

require "rails_helper"

describe DateOfTheNthWeekdayHelper do
  include DateOfTheNthWeekdayHelper

  it "calculates the date of the 2nd wednesday of october 2022 correctly" do
    expect(date_of_nth_weekday(10, 2022, 3, 2)).to eq(Date.new(2022, 10, 12))
  end

  it "calculates the date of the 4th sunday of march 2023 correctly" do
    expect(date_of_nth_weekday(3, 2023, 0, 4)).to eq(Date.new(2023, 3, 26))
  end

  it "calculates the date of the 4th sunday of july 2024 correctly" do
    expect(date_of_nth_weekday(7, 2024, 0, 4)).to eq(Date.new(2024, 7, 28))
  end
end
