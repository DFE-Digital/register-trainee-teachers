# frozen_string_literal: true

module RecordDetails
  class View < GovukComponent::Base
    include SanitizeHelper
    include SummaryHelper

    attr_reader :trainee, :last_updated_event, :not_provided_copy, :show_provider, :show_record_source, :editable

    def initialize(trainee:, last_updated_event:, show_provider: false, show_record_source: false, editable: false)
      @trainee = trainee
      @last_updated_event = last_updated_event
      @show_provider = show_provider
      @editable = editable
      @show_record_source = show_record_source
    end

    def record_detail_rows
      [
        provider_row,
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
      ].compact
    end

  private

    def provider_row
      return unless show_provider

      { field_label: t(".provider"),
        field_value: trainee.provider.name_and_code }
    end

    def record_source_row
      return unless show_record_source

      { field_label: t(".record_source.title"),
        field_value: t(".record_source.#{trainee.derived_record_source}") }
    end

    def trainee_id_row
      mappable_field(trainee.trainee_id.presence, t(".trainee_id"), edit_trainee_training_details_path(trainee))
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

    def trainee_status_tag
      render(StatusTag::View.new(trainee: trainee, classes: "govuk-!-margin-bottom-2")) + tag.br + status_date
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
      return if trainee.start_date.blank?

      start_year = AcademicCycle.for_date(trainee.start_date).label
      {
        field_label: t(".start_year"),
        field_value: start_year,
      }
    end

    def end_year_row
      return if trainee.estimated_end_date.blank?

      end_year = AcademicCycle.for_date(trainee.estimated_end_date).label
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
  end
end
