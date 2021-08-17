# frozen_string_literal: true

class InvalidDataText::View < GovukComponent::Base
  include TraineeHelper

  def initialize(form_section:, hint: "", degree_form:)
    @data_text = invalid_data_message(form_section.to_s, degree_form.degree) unless degree_form.errors.any?
    @hint_text = hint
  end

  def content
    return hint if data_text.blank?

    hint << tag.div(data_text, class: "app-inset-text__title govuk-!-margin-bottom-3")
  end

private

  attr_reader :hint_text, :data_text

  def hint
    tag.div(hint_text, class: "govuk-hint")
  end
end
