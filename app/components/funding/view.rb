# frozen_string_literal: true

module Funding
  class View < GovukComponent::Base
    include SanitizeHelper
    include FundingHelper

    def initialize(data_model:, has_errors: false)
      @data_model = data_model
      @has_errors = has_errors
    end

    def trainee
      data_model.is_a?(Trainee) ? data_model : data_model.trainee
    end

    def title
      t(".title")
    end

    def funding_detail_rows
      [
        training_initiative_row,
        funding_method_row,
      ].compact
    end

  private

    attr_accessor :data_model, :has_errors

    def training_initiative_row
      mappable_field(training_initiative, t(".training_initiative"), edit_trainee_funding_training_initiative_path(trainee))
    end

    def funding_method_row
      return unless show_bursary_funding?

      mappable_field(
        funding_method,
        t(".funding_method"),
        (edit_trainee_funding_bursary_path(trainee) if funding_manager.can_apply_for_bursary?),
      )
    end

    def course_subject_one
      trainee.course_subject_one
    end

    def show_bursary_funding?
      !trainee.draft? || funding_manager.can_apply_for_bursary?
    end

    def bursary_amount
      @bursary_amount ||= funding_manager.bursary_amount
    end

    def training_initiative
      return if data_model.training_initiative.nil?

      t("activerecord.attributes.trainee.training_initiatives.#{data_model.training_initiative}")
    end

    def funding_method
      return if funding_manager.can_apply_for_bursary? && data_model.applying_for_bursary.nil?

      return t(".no_funding_available") if !funding_manager.can_apply_for_bursary?

      return "#{t(".tiered_bursary_applied_for.#{data_model.bursary_tier}")}#{bursary_funding_hint}".html_safe if data_model.bursary_tier.present?

      return "#{t('.bursary_applied_for')}#{bursary_funding_hint}".html_safe if data_model.applying_for_bursary

      t(".no_bursary_applied_for")
    end

    def bursary_funding_hint
      "<br>#{tag.span("#{format_currency(bursary_amount)} estimated bursary", class: 'govuk-hint')}"
    end

    def mappable_field(field_value, field_label, section_url)
      MappableFieldRow.new(
        field_value: field_value,
        field_label: field_label,
        text: t("components.confirmation.missing"),
        action_url: section_url,
        has_errors: has_errors,
      ).to_h
    end

    def funding_manager
      @funding_manager ||= FundingManager.new(trainee)
    end
  end
end
