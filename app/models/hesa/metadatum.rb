# frozen_string_literal: true

module Hesa
  class Metadatum < ApplicationRecord
    self.table_name = "hesa_metadata"

    belongs_to :trainee
  end
end
