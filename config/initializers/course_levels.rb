# frozen_string_literal: true

COURSE_LEVELS = {
  early_years: [
    AgeRange::ZERO_TO_FIVE,
  ],
  primary: [
    AgeRange::THREE_TO_SEVEN,
    AgeRange::THREE_TO_EIGHT,
    AgeRange::THREE_TO_NINE,
    AgeRange::FIVE_TO_NINE,
    AgeRange::THREE_TO_ELEVEN,
    AgeRange::FIVE_TO_ELEVEN,
    AgeRange::SEVEN_TO_ELEVEN,
  ],
  secondary: [
    AgeRange::FIVE_TO_FOURTEEN,
    AgeRange::SEVEN_TO_FOURTEEN,
    AgeRange::SEVEN_TO_SIXTEEN,
    AgeRange::NINE_TO_FOURTEEN,
    AgeRange::NINE_TO_SIXTEEN,
    AgeRange::ELEVEN_TO_SIXTEEN,
    AgeRange::ELEVEN_TO_EIGHTEEN,
    AgeRange::ELEVEN_TO_NINETEEN,
    AgeRange::FOURTEEN_TO_NINETEEN,
  ],
}.freeze
