# frozen_string_literal: true

module RecordDetails
  class View < ApplicationComponent
    include SanitizeHelper
    include SummaryHelper
    include SchoolHelper
    include LeadPartnerHelper

    attr_reader :trainee,
                :last_updated_event,
                :not_provided_copy,
                :show_provider,
                :show_record_source,
                :editable,
                :show_change_provider

    delegate :lead_partner,
             :employing_school,
             :lead_partner_not_applicable?,
             :employing_school_not_applicable?, to: :trainee

    def initialize(
      trainee:,
      last_updated_event:,
      show_provider: false,
      show_record_source: false,
      editable: false,
      show_change_provider: false
    )
      @trainee = trainee
      @last_updated_event = last_updated_event
      @show_provider = show_provider
      @editable = editable
      @show_record_source = show_record_source
      @show_change_provider = show_change_provider
    end

    def record_detail_rows
      rows = [provider_row]
      if trainee.requires_lead_partner?
        rows += [
          lead_partner_row,
          employing_school_row,
        ]
      end
      rows += [
        record_source_row,
        trainee_id_row,
        region,
        trn_row,
        hesa_id_row,
        last_updated_row,
        record_created_row,
        start_year_row,
        end_year_row,
        trainee_start_date_row,
      ]
      rows.compact
    end

  private

    def provider_row
      return unless show_provider

      change_link = show_change_provider ? edit_trainee_accredited_providers_provider_path(trainee_id: trainee.id) : nil
      mappable_field(
        trainee.provider.name_and_code,
        t(".provider"),
        change_link,
      )
    end

    def record_source_row
      return unless show_record_source

      { field_label: t(".record_source.title"),
        field_value: t(".record_source.#{trainee.derived_record_source}") }
    end

    def trainee_id_row
      mappable_field(trainee.provider_trainee_id.presence, t(".provider_trainee_id"), edit_trainee_training_details_path(trainee))
    end

    def region
      return unless trainee&.provider&.hpitt_postgrad?

      { field_label: t(".region"), field_value: trainee.region.presence }
    end

    def trn_row
      return nil unless [trainee.trn, trainee.submitted_for_trn_at].any?(&:present?)

      if trainee.trn.present?
        {
          field_label: t(".trn"),
          field_value: trainee.trn,
        }
      else
        {
          field_label: t(".submitted_for_trn"),
          field_value: submission_date,
        }
      end
    end

    def last_updated_row
      {
        field_label: t(".last_updated"),
        field_value: last_updated_date,
      }
    end

    def record_created_row
      {
        field_label: t(".record_created"),
        field_value: date_for_summary_view(trainee.created_at),
      }
    end

    def trainee_start_date_row
      start_date = RecordDetails::TraineeStartDate.new(trainee)
      start_date_text = start_date.text
      if start_date.course_empty? && trainee.hesa_record?
        start_date_text = t("components.confirmation.not_provided_from_hesa_update")
      elsif start_date.course_empty?
        return
      end

      mappable_field(start_date_text, t(".trainee_start_date"), start_date.link)
    end

    def start_year_row
      return if trainee.start_academic_cycle.blank?

      start_year = trainee.start_academic_cycle.label
      {
        field_label: t(".start_year"),
        field_value: start_year,
      }
    end

    def end_year_row
      return if trainee.end_academic_cycle.blank?

      end_year = trainee.end_academic_cycle.label
      {
        field_label: t(".end_year"),
        field_value: end_year,
      }
    end

    def hesa_id_row
      return unless trainee.hesa_record?

      {
        field_label: t(".hesa_id"),
        field_value: trainee.hesa_id,
      }
    end

    def render_text_with_hint(date)
      hint_text = tag.span("#{time_ago_in_words(date)} ago", class: "govuk-hint")

      sanitize(tag.p(date_for_summary_view(date), class: "govuk-body") + hint_text)
    end

    def submission_date
      render_text_with_hint(trainee.submitted_for_trn_at)
    end

    def last_updated_date
      render_text_with_hint(last_updated_event.date) if last_updated_event.present?
    end

    def progress_date
      return unless trainee_progress_date

      I18n.t("record_details.view.progress_date_prefix.#{trainee.state}") + date_for_summary_view(trainee_progress_date)
    end

    def status_date
      if trainee.itt_not_yet_started?
        return I18n.t("deferral_details.view.deferred_before_itt_started").html_safe if trainee.starts_course_in_the_future?

        return I18n.t("deferral_details.view.itt_started_but_trainee_did_not_start").html_safe
      end

      return unless trainee_status_date

      I18n.t("record_details.view.status_date_prefix.#{trainee.state}") + date_for_summary_view(trainee_status_date)
    end

    def trainee_progress_date
      {
        recommended_for_award: trainee.recommended_for_award_at,
        awarded: trainee.awarded_at,
      }[trainee.state.to_sym]
    end

    def trainee_status_date
      {
        deferred: trainee.defer_date,
        withdrawn: trainee.withdraw_date,
      }[trainee.state.to_sym]
    end

    def mappable_field(field_value, field_label, action_url)
      { field_value:, field_label:, action_url: }
    end

    def change_paths(school_type)
      {
        lead: edit_trainee_lead_partners_details_path(trainee),
        employing: edit_trainee_employing_schools_details_path(trainee),
      }[school_type.to_sym]
    end
  end
end
