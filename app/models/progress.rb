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
  attribute :placements, :boolean, default: false
  attribute :diversity, :boolean, default: false
  attribute :course_details, :boolean, default: false
  attribute :training_details, :boolean, default: false
  attribute :trainee_start_status, :boolean, default: false
  attribute :trainee_data, :boolean, default: false
  attribute :schools, :boolean, default: false
  attribute :funding, :boolean, default: false
  attribute :iqts_country, :boolean, default: false
  attribute :level_five_declaration, :boolean, default: false

  # Funding to be checked again because the degree or employing school it
  # depends on changed after it was started (Funding::RecheckAfterChange).
  # Cleared when the funding section is marked complete.
  attribute :funding_recheck_degree, :boolean, default: false
  attribute :funding_recheck_employing_school, :boolean, default: false

  # After a draft trainee's course details change (Trainees::RecheckAfterCourseChange):
  # the funding and the training partner and employing school to be checked
  # again, or why the funding was removed ("route" or "subject").
  attribute :funding_recheck_course_details, :boolean, default: false
  attribute :schools_recheck_course_details, :boolean, default: false
  attribute :funding_removed_reason, :string

  # After a draft EYTDA trainee's Level 5 declaration answer changes
  # (Trainees::RecheckAfterLevelFiveChange): the course details and funding to be
  # checked again. Each is cleared when its section is marked complete.
  attribute :course_details_recheck_level_five_declaration, :boolean, default: false
  attribute :funding_recheck_level_five_declaration, :boolean, default: false

  def funding_recheck_changes
    [
      (:level_five_declaration if funding_recheck_level_five_declaration),
      (:course_details if funding_recheck_course_details),
      (:degree if funding_recheck_degree),
      (:employing_school if funding_recheck_employing_school),
    ].compact
  end

  def clear_funding_recheck
    self.funding_recheck_course_details = false
    self.funding_recheck_degree = false
    self.funding_recheck_employing_school = false
    self.funding_recheck_level_five_declaration = false
    self.funding_removed_reason = nil
  end

  def clear_course_details_recheck
    self.course_details_recheck_level_five_declaration = false
  end

  def clear_schools_recheck
    self.schools_recheck_course_details = false
  end
end
