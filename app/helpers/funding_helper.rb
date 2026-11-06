# frozen_string_literal: true

module FundingHelper
  def training_initiative_options(trainee)
    Funding::AvailableTrainingInitiativesService.call(academic_cycle: trainee.start_academic_cycle).sort
  end

  def funding_options(trainee)
    can_start_funding_section?(trainee) ? :funding_active : :funding_inactive
  end

  # Where the provider adds what the funding depends on (FundingManager#funding_prerequisites).
  def funding_prerequisite_path(trainee, prerequisite)
    prerequisite.to_sym == :degree ? path_for_degrees(trainee) : edit_trainee_training_partners_details_path(trainee)
  end

  # What changed since the funding was added, for the "check the funding again"
  # messages: "course details", "degree and employing school"…, or nil.
  def funding_recheck_changed(trainee)
    changes = trainee.progress.funding_recheck_changes
    return if changes.empty? || trainee.progress.funding

    changes.map { |change| I18n.t("views.forms.funding.recheck.changes.#{change}") }.to_sentence
  end

  # "route" or "subject" when the funding was removed with the course, until it's added again.
  def funding_removed_reason(trainee)
    return if trainee.progress.funding
    return if [trainee.training_initiative, trainee.applying_for_bursary, trainee.applying_for_scholarship, trainee.applying_for_grant].any? { |choice| !choice.nil? }

    trainee.progress.funding_removed_reason
  end

  # The training partner and employing school to be confirmed again after a course details change.
  def schools_recheck?(trainee)
    trainee.progress.schools_recheck_course_details && !trainee.progress.schools
  end

  # The course details to be confirmed again after the Level 5 declaration changed.
  def course_details_recheck?(trainee)
    trainee.progress.course_details_recheck_level_five_declaration && !trainee.progress.course_details
  end

  def format_currency(amount)
    number_to_currency(
      amount,
      unit: "£",
      locale: :en,
      strip_insignificant_zeros: true,
    )
  end

  def funding_csv_export_path(funding_type)
    return polymorphic_path([:funding, funding_type], format: :csv) unless current_user.system_admin?

    polymorphic_path([:provider, :funding, funding_type], format: :csv)
  end

private

  def can_start_funding_section?(trainee)
    trainee.progress.course_details && trainee.start_academic_cycle.present?
  end
end
