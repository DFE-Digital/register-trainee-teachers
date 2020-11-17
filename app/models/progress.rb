# frozen_string_literal: true

class Progress
  include StoreModel::Model

  STATUSES = {
    not_started: "not started",
    in_progress: "in progress",
    completed: "completed",
  }.freeze

  attribute :personal_details, :boolean
  attribute :contact_details, :boolean
  attribute :degrees, :boolean
  attribute :diversity, :boolean
  attribute :programme_details, :boolean
end
