# frozen_string_literal: true

module Funding
  class View < ApplicationComponent
    include SanitizeHelper
    include FundingHelper

    def initialize(data_model:, has_errors: false, editable: false, header_level: 2)
      @data_model = data_model
      @has_errors = has_errors
      @editable = editable
      @header_level = header_level
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
        fund_code_row,
        applying_for_bursary_row,
        selected_bursary_level_row,
      ].compact
    end

  private

    attr_accessor :data_model, :has_errors, :editable, :header_level

    delegate :can_apply_for_tiered_bursary?, :can_apply_for_scholarship?, :scholarship_amount,
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
      return if (no_funding_methods? && data_model.bursary_tier.blank?) || data_model.training_initiative == "troops_to_teachers"

      if can_apply_for_tiered_bursary?
        if can_apply_for_grant?
          grant_and_bursary_funding_row
        else
          bursary_funding_row
        end
      elsif can_apply_for_grant?
        grant_funding_row
      elsif data_model.applying_for_scholarship
        scholarship_funding_row
      else
        bursary_funding_row
      end
    end

    def grant_and_bursary_funding_row
      funding_text = [grant_text, "<br>", funding_method].join.html_safe

      # Set funding_text to nil if applying_for_grant is nil, which means not all the fields were set for the GrantAndTieredBursaryForm
      funding_text = nil if data_model.applying_for_grant.nil?

      mappable_field(
        funding_text,
        t(".funding_method"),
        edit_trainee_funding_bursary_path(trainee),
      )
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

    def grant_text
      if data_model.applying_for_grant
        t(".grant_applied_for") + "<br>#{tag.span("#{format_currency(grant_amount)} estimated grant", class: 'govuk-hint')}"
      else
        t(".no_grant_applied_for")
      end
    end

    def grant_funding_row
      funding_text = grant_text
      # In some cases, applying_for_grant can actually be nil which means it wasn't set properly during import.
      # We should let the user know that this field is missing data and should be filled in manually.
      funding_text = nil if data_model.applying_for_grant.nil?

      mappable_field(funding_text&.html_safe, t(".funding_method"), edit_trainee_funding_bursary_path(trainee))
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

    def fund_code_row
      return unless trainee.hesa_record? && trainee.hesa_trainee_detail&.fund_code.present?

      fund_code_value = trainee.hesa_trainee_detail.fund_code
      fund_code_description = Hesa::CodeSets::FundCodes::MAPPING[fund_code_value]
      fund_code_text = "#{fund_code_value} - #{fund_code_description}"

      mappable_field(fund_code_text, t(".fund_code"), nil)
    end

    def applying_for_bursary_row
      return unless trainee.hesa_record?

      mappable_field(trainee.applying_for_bursary ? t(".applying") : t(".not_applying"), t(".applying_for_bursary"), nil)
    end

    def selected_bursary_level_row
      return unless trainee.hesa_record? && trainee.applying_for_bursary? && hesa_student.present?

      hesa_bursary_level = Hesa::CodeSets::BursaryLevels::VALUES[hesa_student.bursary_level]
      hesa_bursary_text = "#{hesa_student.bursary_level} - #{hesa_bursary_level}"

      mappable_field(hesa_bursary_text, t(".selected_bursary_level"), nil)
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

    def no_funding_methods?
      !trainee.start_academic_cycle || trainee.start_academic_cycle.funding_methods.none?
    end

    def mappable_field(field_value, field_label, action_url)
      { field_value:, field_label:, action_url: }
    end

    def funding_manager
      @funding_manager ||= FundingManager.new(trainee)
    end

    def hesa_student
      @hesa_student ||= trainee.hesa_student_for_collection(Settings.hesa.current_collection_reference)
    end
  end
end
