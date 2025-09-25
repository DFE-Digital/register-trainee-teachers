# frozen_string_literal: true

class InvalidDataText::View < ApplicationComponent
  include TraineeHelper

  def initialize(form_section:, hint: "", degree_form:)
    @data_text = invalid_data_message(form_section.to_s, degree_form.degree)
    @hint_text = hint
    @degree_form = degree_form
    @form_section = form_section
  end

  def content
    return hint if data_text.blank?
    return hint if form_section_valid?
    return tag.div(data_text, class: text_class) if hint.nil?

    hint << tag.div(data_text, class: text_class)
  end

private

  attr_reader :hint_text, :data_text, :degree_form, :form_section

  def hint
    return nil if hint_text.blank?

    tag.div(hint_text, class: "govuk-hint")
  end

  def form_section_valid?
    degree_form.errors.any? && degree_form.errors.messages.keys.exclude?(form_section)
  end

  def text_class
    degree_form.errors.any? ? "govuk-error-message" : "app-inset-text__title govuk-!-margin-bottom-3"
  end
end
