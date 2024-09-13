# frozen_string_literal: true

module Trainees
  module CreateFromCsvRow
    class TeachFirst < Base
      def initialize(csv_row:)
        provider = Provider.find_by!(code: "1TF")
        super(csv_row:, provider:)
      end
    end
  end
end
