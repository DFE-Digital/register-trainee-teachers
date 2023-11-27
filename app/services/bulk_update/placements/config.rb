# frozen_string_literal: true

module BulkUpdate
  module Placements
    module Config
      # regex
      VALID_TRN = /^\d{7}$/ # 1234567

      # constants
      ENCODING = "UTF-8"
      FIRST_CSV_ROW_NUMBER = 2
      CSV_ARGS = { headers: true, header_converters: :downcase, strip: true, encoding: ENCODING }.freeze
    end
  end
end
