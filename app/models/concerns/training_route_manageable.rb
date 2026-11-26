# frozen_string_literal: true

module TrainingRouteManageable
  delegate :award_type,
           :requires_training_partner?,
           :requires_placements?,
           :minimum_placements,
           :requires_employing_school?,
           :requires_assessment_only_employing_school?,
           :early_years_route?,
           :undergrad_route?,
           :requires_itt_start_date?,
           :requires_study_mode?,
           :requires_degree?,
           :requires_funding?,
           :requires_iqts_country?,
           :requires_level_five_declaration?,
           :requires_training_initiative?,
           :requires_employing_setting?,
           :level_five_course_years,
           :level_five_course_months,
           to: :training_route_manager

  def training_route_manager
    @training_route_manager ||= TrainingRouteManager.new(self)
  end
end
