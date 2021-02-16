# frozen_string_literal: true

class TraineeSection::View < ViewComponent::Base

  attr_accessor :trainee, :section, :validator, :confirmation_view

  def initialize(trainee:, section:)
    @trainee = trainee
    @section = section

    case section
    when :personal_details
      @validator = PersonalDetailForm
      @confirmation_view = Trainees::Confirmation::PersonalDetails::View
    when :contact_details
      @validator = ContactDetailForm
      @confirmation_view = Trainees::Confirmation::ContactDetails::View
    when :diversity
      @validator = Diversities::FormValidator
      @confirmation_view = Trainees::Confirmation::Diversity::View
    when :degrees
      @validator = DegreeDetailForm
      @confirmation_view = Trainees::Confirmation::Degrees::View
    when :programme_details
      @validator = ProgrammeDetailForm
      @confirmation_view = Trainees::Confirmation::ProgrammeDetails::View
    end
  end

  def status
    status = ProgressService.call(
      validator: validator.new(trainee),
      progress_value: trainee.progress.public_send(section)
    ).status

    status = status.parameterize(separator: '_').to_sym
  end

  def is_completed
  end

  def title
    I18n.t("components.missing_details.#{section}.#{status}.title")

  end

  def url
    return is_completed

    # I18n.t("components.missing_details.#{section}.#{status}.url")

    get_path
  end

  def get_path
    not_started_path_hash || not_complete_path_hash
  end

  def not_started_path_hash
    {
      personal_details: edit_trainee_personal_details_path(@trainee),
      contact_details: edit_trainee_contact_details_path(@trainee),
      diversity: edit_trainee_diversity_disability_disclosure_path(@trainee),
      degrees: trainee_degrees_new_type_path(@trainee),
      programme_details: edit_trainee_programme_details_path(@trainee),
    }
  end

  def not_complete_path_hash
    {
      personal_details: trainee_personal_details_confirm_path(@trainee),
      contact_details: trainee_contact_details_confirm_path(@trainee),
      diversity: trainee_diversity_confirm_path(@trainee),
      degrees: trainee_degrees_confirm_path(@trainee),
      programme_details: trainee_programme_details_confirm_path(@trainee),
    }
  end

  def link_text
    return is_completed
    I18n.t("components.missing_details.#{section}.#{status}.link_text")
  end
end
