# frozen_string_literal: true

class TraineeSection::View < ViewComponent::Base

  attr_accessor :trainee, :section

  def initialize(trainee:, section:)
    @trainee = trainee
    @section = section
  end

  def component
    if status == :completed
      confirmation_view.new(trainee: trainee)
    else
      BlueInsetTextWithLink::View.new(title: title, link_text: link_text, url: url)
    end
  end

  private 

  def validator
    {
      personal_details: PersonalDetailForm,
      contact_details: ContactDetailForm,
      diversity: Diversities::FormValidator,
      degrees: DegreeDetailForm,
      programme_details: ProgrammeDetailForm
    }[section]
  end

  def confirmation_view
    {
      personal_details: Trainees::Confirmation::PersonalDetails::View,
      contact_details: Trainees::Confirmation::ContactDetails::View,
      diversity: Trainees::Confirmation::Diversity::View,
      degrees: Trainees::Confirmation::Degrees::View,
      programme_details: Trainees::Confirmation::ProgrammeDetails::View,
    }[section]
  end

  def path
    {
      personal_details: { 
        not_started: "edit_trainee_personal_details_path",
        in_progress: "trainee_personal_details_confirm_path"
      },
      contact_details: { 
        not_started: "edit_trainee_contact_details_path",
        in_progress: "trainee_contact_details_confirm_path"
      },
      diversity: { 
        not_started: "edit_trainee_diversity_disability_disclosure_path",
        in_progress: "trainee_diversity_confirm_path"
      },
      degrees: { 
        not_started: "trainee_degrees_new_type_path",
        in_progress: "trainee_degrees_confirm_path"
      },
      programme_details: { 
        not_started: "edit_trainee_programme_details_path",
        in_progress: "trainee_programme_details_confirm_path"
      }
    }[section][status]
  end

  def status
    status ||= ProgressService.call(
      validator: validator.new(trainee),
      progress_value: trainee.progress.public_send(section)
    ).status.parameterize(separator: '_').to_sym
  end

  def title
    I18n.t("components.missing_details.#{section}.#{status}.title")
  end

  def url
    Rails.application.routes.url_helpers.public_send(path, trainee)
  end

  def link_text
    I18n.t("components.missing_details.#{section}.#{status}.link_text")
  end
end
