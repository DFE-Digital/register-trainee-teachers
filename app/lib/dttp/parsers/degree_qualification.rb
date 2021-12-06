# frozen_string_literal: true

module Dttp
  module Parsers
    class DegreeQualification
      class << self
        def to_attributes(degree_qualifications:)
          degree_qualifications.map do |degree_qualification|
            {
              dttp_id: degree_qualification["dfe_degreequalificationid"],
              contact_dttp_id: degree_qualification["_dfe_contactid_value"],
              response: degree_qualification,
            }
          end
        end
      end
    end
  end
end
