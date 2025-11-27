# frozen_string_literal: true

module BulkUpdate
  module AddTrainees
    module Config
      # regex
      VALID_HESA_ID = /^["']?[0-9]{13}(?:[0-9]{4})?["']?$/ # 13 or 17 number string with or without quotes
      VALID_TRN = /^\d{7}$/ # 1234567
      VALID_STANDARDS_MET_AT = /^\d{1,2}[\/-]\d{1,2}[\/-]\d{4}$/ # dd/mm/yyyy or dd-mm-yyyy or d/m/yyyy etc etc

      # constants
      ENCODING = "UTF-8"
      FIRST_CSV_ROW_NUMBER = 2
      CSV_ARGS = { headers: true, strip: true, encoding: ENCODING }.freeze
      VERSION  = Settings.bulk_update.add_trainees.version
    end
  end
end
