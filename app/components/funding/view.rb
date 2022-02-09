# frozen_string_literal: true

module Funding
  class View < GovukComponent::Base
    include SanitizeHelper
    include FundingHelper

    def initialize(data_model:, has_errors: false, editable: false)
      @data_model = data_model
      @has_errors = has_errors
      @editable = editable
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

    attr_accessor :data_model, :has_errors, :editable

    delegate :can_apply_for_scholarship?, :scholarship_amount,
             :can_apply_for_bursary?, :bursary_amount,
             :can_apply_for_grant?, :grant_amount,
             :can_apply_for_funding_type?,
             to: :funding_manager

    def training_initiative_row
      mappable_field(
        training_initiative,
        t(".training_initiative"),
        edit_trainee_funding_training_initiative_path(trainee),
      )
    end

    def funding_method_row
      if can_apply_for_grant?
        grant_funding_row
      elsif data_model.applying_for_scholarship
        scholarship_funding_row
      else
        bursary_funding_row
      end
    end

    def bursary_funding_row
      return unless show_bursary_funding?

      mappable_field(
        funding_method,
        t(".funding_method"),
        (edit_trainee_funding_bursary_path(trainee) if can_apply_for_bursary?),
      )
    end

    def show_bursary_funding?
      !trainee.draft? || can_apply_for_funding_type?
    end

    def grant_funding_row
      grant_text = if data_model.applying_for_grant
                     t(".grant_applied_for") + "<br>#{tag.span("#{format_currency(grant_amount)} estimated grant", class: 'govuk-hint')}"
                   else
                     t(".no_grant_applied_for")
                   end

      # In some cases, applying_for_grant can actually be nil which means it wasn't set properly during import.
      # We should let the user know that this field is missing data and should be filled in manually.
      grant_text = nil if data_model.applying_for_grant.nil?

      mappable_field(grant_text&.html_safe, t(".funding_method"), edit_trainee_funding_bursary_path(trainee))
    end

    def scholarship_funding_row
      scholarship_text = t(".scholarship_applied_for") +
        "<br>#{tag.span("#{format_currency(scholarship_amount)} estimated scholarship", class: 'govuk-hint')}"

      mappable_field(
        scholarship_text.html_safe,
        t(".funding_method"),
        edit_trainee_funding_bursary_path(trainee),
      )
    end

    def training_initiative
      return if data_model.training_initiative.nil?

      t("activerecord.attributes.trainee.training_initiatives.#{data_model.training_initiative}")
    end

    def funding_method
      return if can_apply_for_bursary? && data_model.applying_for_bursary.nil?

      return t(".no_funding_available") if !can_apply_for_bursary?

      return "#{t(".tiered_bursary_applied_for.#{data_model.bursary_tier}")}#{bursary_funding_hint}".html_safe if data_model.bursary_tier.present?

      return "#{t('.bursary_applied_for')}#{bursary_funding_hint}".html_safe if data_model.applying_for_bursary

      t(".no_bursary_applied_for")
    end

    def bursary_funding_hint
      "<br>#{tag.span("#{format_currency(bursary_amount)} estimated bursary", class: 'govuk-hint')}"
    end

    def mappable_field(field_value, field_label, action_url)
      { field_value: field_value, field_label: field_label, action_url: action_url }
    end

    def funding_manager
      @funding_manager ||= FundingManager.new(trainee)
    end
  end
end
