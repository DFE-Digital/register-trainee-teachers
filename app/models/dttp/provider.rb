# frozen_string_literal: true

# == Schema Information
#
# Table name: dttp_providers
#
#  id         :bigint           not null, primary key
#  name       :string
#  response   :jsonb
#  ukprn      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  dttp_id    :uuid
#
# Indexes
#
#  index_dttp_providers_on_dttp_id  (dttp_id) UNIQUE
#
module Dttp
  class Provider < ApplicationRecord
    self.table_name = "dttp_providers"

    belongs_to :provider, class_name: "::Provider", primary_key: :dttp_id, foreign_key: :dttp_id, optional: true
  end
end
