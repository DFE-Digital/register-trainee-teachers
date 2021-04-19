# frozen_string_literal: true

module Dttp
  class Provider < ApplicationRecord
    self.table_name = "dttp_providers"

    include PgSearch::Model

    pg_search_scope :search_by_name, against: %i[name], using: { tsearch: { prefix: true } }

    belongs_to :provider, class_name: "::Provider", primary_key: :dttp_id, foreign_key: :dttp_id, optional: true
  end
end
