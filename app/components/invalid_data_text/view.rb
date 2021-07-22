# frozen_string_literal: true

class InvalidDataText::View < GovukComponent::Base
  include TraineeHelper
  attr_reader :hint_text, :trainee, :form_section

  def initialize(trainee:, form_section:, hint: "")
    @trainee = trainee
    @form_section = form_section.to_s
    @hint_text = hint
  end

  def content
    if invalid_data_message(form_section, trainee)
      hint << tag.div(invalid_data_message(form_section, trainee), class: "app-inset-text__title govuk-!-margin-bottom-3")
    else
      hint
    end
  end

private

  def hint
    tag.div(hint_text, class: "govuk-hint")
  end
end
