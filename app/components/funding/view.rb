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
        bursary_funding_row,
      ].compact
    end

  private

    attr_accessor :data_model, :has_errors

    def training_initiative_row
      mappable_field(training_initiative, t(".training_initiative"), edit_trainee_funding_training_initiative_path(trainee))
    end

    def bursary_funding_row
      return unless show_bursary_funding?

      mappable_field(
        bursary_funding,
        t(".bursary_funding"),
        (edit_trainee_funding_bursary_path(trainee) if trainee.can_apply_for_bursary?),
      )
    end

    def course_subject_one
      trainee.course_subject_one
    end

    def show_bursary_funding?
      !trainee.draft? || trainee.can_apply_for_bursary?
    end

    def bursary_amount
      @bursary_amount ||= if trainee.bursary_tier.present?
                            CalculateBursary.for_tier(trainee.bursary_tier)
                          else
                            trainee.bursary_amount
                          end
    end

    def training_initiative
      return if trainee.training_initiative.nil?

      t("activerecord.attributes.trainee.training_initiatives.#{trainee.training_initiative}")
    end

    def bursary_funding
      return if trainee.can_apply_for_bursary? && trainee.applying_for_bursary.nil?

      return t(".no_bursary_available") if !trainee.can_apply_for_bursary?

      return "#{t(".tiered_bursary_applied_for.#{trainee.bursary_tier}")}#{bursary_funding_hint}".html_safe if trainee.bursary_tier.present?

      return "#{t('.bursary_applied_for')}#{bursary_funding_hint}".html_safe if trainee.applying_for_bursary

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
  end
end
