# frozen_string_literal: true

module Dttp
  module Parsers
    class BursaryDetail
      class << self
        def to_attributes(bursary_details:)
          bursary_details.map do |bursary_detail|
            {
              dttp_id: bursary_detail["dfe_bursarydetailid"],
              response: bursary_detail,
            }
          end
        end
      end
    end
  end
end
