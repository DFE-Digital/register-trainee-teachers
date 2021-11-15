# frozen_string_literal: true

module RecordDetails
  class View < GovukComponent::Base
    include SanitizeHelper
    include SummaryHelper

    attr_reader :trainee, :last_updated_event, :not_provided_copy, :system_admin

    def initialize(trainee:, last_updated_event:, system_admin: false)
      @trainee = trainee
      @last_updated_event = last_updated_event
      @system_admin = system_admin
    end

    def record_detail_rows
      [
        provider_row,
        trainee_id_row,
        region,
        trn_row,
        trainee_progress_row,
        trainee_status_row,
        last_updated_row,
        record_created_row,
        trainee_start_date_row,
      ].compact
    end

  private

    def provider_row
      return unless system_admin

      { field_label: t(".provider"),
        field_value: trainee.provider.name_and_code }
    end

    def trainee_id_row
      mappable_field(trainee.trainee_id.presence, t(".trainee_id"), edit_trainee_training_details_path(trainee))
    end

    def region
      return unless trainee&.provider&.hpitt_postgrad?

      { field_label: t(".region"), field_value: trainee.region.presence }
    end

    def trn_row
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

    def trainee_progress_row
      return unless trainee.recommended_for_award? || trainee.awarded?

      {
        field_label: trainee.award_type,
        field_value: render(StatusTag::View.new(trainee: trainee, classes: "govuk-!-margin-bottom-2")) + tag.br + progress_date,
      }
    end

    def trainee_status_row
      return unless trainee.deferred? || trainee.withdrawn?

      {
        field_label: t(".trainee_status"),
        field_value: render(StatusTag::View.new(trainee: trainee, classes: "govuk-!-margin-bottom-2")) + tag.br + status_date,
      }
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
      return if @trainee.course_start_date.nil?

      if @trainee.course_start_date <= Time.zone.now
        mappable_field(trainee_start_date, t(".trainee_start_date"), edit_trainee_start_date_path(trainee))
      else
        mappable_field(trainee_start_date, t(".trainee_start_date"), nil)
      end
    end

    def render_text_with_hint(date)
      hint_text = tag.span(time_ago_in_words(date).concat(" ago"), class: "govuk-hint")

      sanitize(tag.p(date_for_summary_view(date), class: "govuk-body") + hint_text)
    end

    def trainee_start_date
      return t(".itt_not_yet_started") if trainee.itt_not_yet_started?

      trainee.commencement_date.present? ? date_for_summary_view(trainee.commencement_date) : nil
    end

    def submission_date
      render_text_with_hint(trainee.submitted_for_trn_at)
    end

    def last_updated_date
      render_text_with_hint(last_updated_event.date)
    end

    def progress_date
      return unless trainee_progress_date

      I18n.t("record_details.view.progress_date_prefix.#{trainee.state}") + date_for_summary_view(trainee_progress_date)
    end

    def status_date
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
      { field_value: field_value, field_label: field_label, action_url: action_url }
    end
  end
end
