# frozen_string_literal: true

# == Schema Information
#
# Table name: hesa_trn_requests
#
#  id                   :bigint           not null, primary key
#  collection_reference :string
#  response_body        :text
#  state                :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
module Hesa
  class TrnRequest < ApplicationRecord
    self.table_name = "hesa_trn_requests"

    enum state: { import_failed: 0, import_successful: 1 }
  end
end
