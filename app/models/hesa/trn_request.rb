# frozen_string_literal: true

module Hesa
  class TrnRequest < ApplicationRecord
    self.table_name = "hesa_trn_requests"

    enum state: { import_failed: 0, import_successful: 1 }
  end
end
