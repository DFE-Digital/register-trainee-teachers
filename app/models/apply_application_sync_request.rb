# frozen_string_literal: true

class ApplyApplicationSyncRequest < ApplicationRecord
  scope :successful, -> { where(successful: true) }
  scope :unsuccessful, -> { where(successful: false) }
end
