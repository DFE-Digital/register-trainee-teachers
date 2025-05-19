# frozen_string_literal: true

module TrainingRouteManageable
  delegate :award_type,
           :requires_lead_partner?,
           :requires_placements?,
           :requires_employing_school?,
           :early_years_route?,
           :undergrad_route?,
           :requires_itt_start_date?,
           :requires_study_mode?,
           :requires_degree?,
           :requires_funding?,
           :requires_iqts_country?,
           to: :training_route_manager

private

  def training_route_manager
    @training_route_manager ||= TrainingRouteManager.new(self)
  end
end
