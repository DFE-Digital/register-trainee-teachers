# frozen_string_literal: true

module Hesa
  module CodeSets
    module Grades
      # https://www.hesa.ac.uk/collection/c21053/xml/c21053/c21053codelists.xsd

      OTHER = "Other"

      OTHER_GRADES = %w[
        04
        06
        07
        08
        09
        10
        11
        12
        13
        98
        99
      ].freeze

      MAPPING = {
        "01" => "First-class honours",
        "02" => "Upper second-class honours (2:1)",
        "03" => "Lower second-class honours (2:2)",
        "05" => "Third-class honours",
        "14" => "Pass",

        # Other grades
        "04" => "Undivided second class honours",
        "06" => "Fourth class honours",
        "07" => "Unclassified honours",
        "08" => "Aegrotat (whether to honours or pass)",
        "09" => "Pass - degree awarded without honours following an honours course",
        "10" => "Ordinary (including divisions of ordinary, if any) degree awarded after following a non-honours course",
        "11" => "General degree - degree awarded after following a non-honours course/degree that was not available to be classified",
        "12" => "Distinction",
        "13" => "Merit",
        "98" => "Not applicable",
        "99" => "Not known",
      }.freeze
    end
  end
end
