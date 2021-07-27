# frozen_string_literal: true

class Progress
  include StoreModel::Model

  STATUSES = {
    incomplete: "incomplete",
    in_progress_valid: "in_progress_valid",
    in_progress_invalid: "in_progress_invalid",
    review: "review",
    completed: "completed",
  }.freeze

  attribute :personal_details, :boolean, default: false
  attribute :contact_details, :boolean, default: false
  attribute :degrees, :boolean, default: false
  attribute :diversity, :boolean, default: false
  attribute :course_details, :boolean, default: false
  attribute :training_details, :boolean, default: false
  attribute :placement_details, :boolean, default: false
  attribute :trainee_data, :boolean, default: false
  attribute :schools, :boolean, default: false
  attribute :funding, :boolean, default: false
end
