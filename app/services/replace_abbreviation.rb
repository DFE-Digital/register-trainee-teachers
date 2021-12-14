# frozen_string_literal: true

class ReplaceAbbreviation
  include ServicePattern

  Abbreviation = Struct.new(:string, :normalised) do
    delegate :blank?, :to_s, to: :string
  end

  NORMALISED_PHRASE_MAP = {
    "Church of England" => ["COE", "CofE", "C of E"],
  }.freeze

  def initialize(string: nil)
    @string = string
    @abbreviation = find_abbreviation
  end

  def call
    return string if abbreviation.blank?

    string.gsub(/#{abbreviation}/i, abbreviation.normalised)
  end

private

  attr_reader :string, :abbreviation

  def find_abbreviation
    Abbreviation.new.tap do |abbreviation|
      NORMALISED_PHRASE_MAP.each do |normalised_phrase, phrases|
        abbreviated_phrase = phrases.find { |phrase| string&.downcase&.include?(phrase.downcase) }
        next unless abbreviated_phrase

        abbreviation.string = abbreviated_phrase
        abbreviation.normalised = normalised_phrase

        break
      end
    end
  end
end
