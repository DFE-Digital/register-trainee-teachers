# frozen_string_literal: true

class ApplyApplicationSyncRequest < ApplicationRecord
  scope :successful, -> { where(successful: true) }
end
