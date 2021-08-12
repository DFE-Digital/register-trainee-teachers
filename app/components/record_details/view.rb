# frozen_string_literal: true

module RecordDetails
  class View < GovukComponent::Base
    include SanitizeHelper
    include SummaryHelper

    attr_reader :trainee, :last_updated_event, :not_provided_copy

    def initialize(trainee:, last_updated_event:)
      @trainee = trainee
      @last_updated_event = last_updated_event
    end

    def record_detail_rows
      [
        trainee_id_row,
        trn_row,
        trainee_progress_row,
        trainee_status_row,
        last_updated_row,
        record_created_row,
        trainee_start_date_row,
      ].compact
    end

  private

    def trainee_id_row
      mappable_field(trainee.trainee_id.presence, t(".trainee_id"), edit_trainee_trainee_id_path(trainee))
    end

    def trn_row
      if trainee.trn.present?
        {
          key: t(".trn"),
          value: trainee.trn,
        }
      else
        {
          key: t(".submitted_for_trn"),
          value: submission_date,
        }
      end
    end

    def trainee_progress_row
      return unless trainee.recommended_for_award? || trainee.awarded?

      {
        key: trainee.award_type,
        value: render(StatusTag::View.new(trainee: trainee, classes: "govuk-!-margin-bottom-2")) + tag.br + progress_date,
      }
    end

    def trainee_status_row
      return unless trainee.deferred? || trainee.withdrawn?

      {
        key: t(".trainee_status"),
        value: render(StatusTag::View.new(trainee: trainee, classes: "govuk-!-margin-bottom-2")) + tag.br + status_date,
      }
    end

    def last_updated_row
      {
        key: t(".last_updated"),
        value: last_updated_date,
      }
    end

    def record_created_row
      {
        key: t(".record_created"),
        value: date_for_summary_view(trainee.created_at),
      }
    end

    def trainee_start_date_row
      mappable_field(trainee_start_date, t(".trainee_start_date"), edit_trainee_start_date_path(trainee))
    end

    def render_text_with_hint(date)
      hint_text = tag.span(time_ago_in_words(date).concat(" ago"), class: "govuk-hint")

      sanitize(tag.p(date_for_summary_view(date), class: "govuk-body") + hint_text)
    end

    def trainee_start_date
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

      I18n.t(".progress_date_prefix.#{trainee.state}") + date_for_summary_view(trainee_progress_date)
    end

    def status_date
      return unless trainee_status_date

      I18n.t(".status_date_prefix.#{trainee.state}") + date_for_summary_view(trainee_status_date)
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

    def mappable_field(field_value, field_label, section_url)
      MappableFieldRow.new(
        field_value: field_value,
        field_label: field_label,
        text: t("components.confirmation.missing"),
        action_url: section_url,
      ).to_h
    end
  end
end
