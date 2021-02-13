# frozen_string_literal: true

class MissingDetails::View < ViewComponent::Base
  attr_reader :section, :progress, :trainee

  def initialize(section:, progress:, trainee:)
    @section = section
    @progress = progress
    @trainee = trainee
  end

  def title
    I18n.t("components.missing_details.#{progress}_title.#{section}")
  end

  def link_text
    not_started? ? "Start section" : "Continue section"
  end

  def path
    not_started? ? not_started_path_hash[@section] : not_complete_path_hash[@section]
  end

  def not_started_path_hash
    {
      personal_details: edit_trainee_personal_details_path(trainee),
      contact_details: edit_trainee_contact_details_path(trainee),
      diversity: edit_trainee_diversity_disability_disclosure_path(trainee),
      degrees: trainee_degrees_new_type_path(trainee),
      programme_details: edit_trainee_programme_details_path(trainee),
    }
  end

  def not_complete_path_hash
    {
      personal_details: trainee_personal_details_confirm_path(trainee),
      contact_details: trainee_contact_details_confirm_path(trainee),
      diversity: trainee_diversity_confirm_path(trainee),
      degrees: trainee_degrees_confirm_path(trainee),
      programme_details: trainee_programme_details_confirm_path(trainee),
    }
  end

private

  def not_started?
    progress == :not_started
  end
end
