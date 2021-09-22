# frozen_string_literal: true

COURSE_LEVELS = {
  early_years: [
    AgeRange::ZERO_TO_FIVE,
  ],
  primary: [
    AgeRange::TWO_TO_SEVEN,
    AgeRange::TWO_TO_ELEVEN,
    AgeRange::THREE_TO_SEVEN,
    AgeRange::THREE_TO_EIGHT,
    AgeRange::THREE_TO_NINE,
    AgeRange::THREE_TO_ELEVEN,
    AgeRange::FOUR_TO_ELEVEN,
    AgeRange::FIVE_TO_NINE,
    AgeRange::FIVE_TO_ELEVEN,
    AgeRange::SEVEN_TO_ELEVEN,
  ],
  secondary: [
    AgeRange::TWO_TO_NINETEEN,
    AgeRange::THREE_TO_SIXTEEN,
    AgeRange::FOUR_TO_NINETEEN,
    AgeRange::FIVE_TO_FOURTEEN,
    AgeRange::FIVE_TO_EIGHTEEN,
    AgeRange::SEVEN_TO_FOURTEEN,
    AgeRange::SEVEN_TO_SIXTEEN,
    AgeRange::SEVEN_TO_EIGHTEEN,
    AgeRange::NINE_TO_THIRTEEN,
    AgeRange::NINE_TO_FOURTEEN,
    AgeRange::NINE_TO_SIXTEEN,
    AgeRange::ELEVEN_TO_SIXTEEN,
    AgeRange::ELEVEN_TO_EIGHTEEN,
    AgeRange::ELEVEN_TO_NINETEEN,
    AgeRange::THIRTEEN_TO_EIGHTEEN,
    AgeRange::FOURTEEN_TO_EIGHTEEN,
    AgeRange::FOURTEEN_TO_NINETEEN,
  ],
}.freeze
