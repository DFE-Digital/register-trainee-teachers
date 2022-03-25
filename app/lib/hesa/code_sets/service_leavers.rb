# frozen_string_literal: true

module Hesa
  module CodeSets
    module ServiceLeavers
      # https://www.hesa.ac.uk/collection/c21053/xml/c21053/c21053codelists.xsd
      # https://www.hesa.ac.uk/collection/c21053/e/serleave
      MAPPING = {
        "01" => "Trainee has not left full time employment in the British Army, Royal Air Force or Royal Navy within 5 years of beginning the programme",
        "02" => "Trainee left full time employment in the British Army, Royal Air Force or Royal Navy within 5 years of beginning the programme",
        "03" => "Prefer not to say",
        "09" => "Unknown",
      }.freeze
    end
  end
end
