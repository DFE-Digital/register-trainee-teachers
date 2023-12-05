# frozen_string_literal: true

module BulkUpdate
  module Placements
    module Config
      # regex
      VALID_TRN = /^\d{7}$/ # 1234567
      VALID_ITT_START_DATE = /^\d{1,2}[\/-]\d{1,2}[\/-]\d{4}$/ # dd/mm/yyyy or dd-mm-yyyy or d/m/yyyy etc etc
      VALID_URN = /^\d{6}$/ # 123456

      # constants
      MAX_PLACEMENTS = 2 # number of "Placement <n> URN" columns given to user to fill
      ENCODING = "UTF-8"
      FIRST_CSV_ROW_NUMBER = 2
      CSV_ARGS = { headers: true, header_converters: :downcase, strip: true, encoding: ENCODING }.freeze
    end
  end
end
