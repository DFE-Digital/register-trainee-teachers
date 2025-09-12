# frozen_string_literal: true

module DeferralDetails
  class View < ApplicationComponent
    include SummaryHelper

    attr_reader :data_model, :editable

    def initialize(data_model, editable: true, omit_start_date: false)
      @data_model = data_model
      @omit_start_date = omit_start_date
      @editable = editable
    end

    def rows
      rows = [deferral_date_row]
      rows.unshift(trainee_start_date_row) unless @omit_start_date
      rows << trainee_defer_reason_row
      rows.compact
    end

    def trainee_start_date_row
      return unless trainee_started_itt?

      {
        key: t(".start_date_label"),
        value: trainee_start_date,
        action_href: trainee_start_date_verification_path(data_model.trainee, context: :defer),
        action_text: t(:change),
        action_visually_hidden_text: "itt start date",
      }
    end

    def deferral_date_row
      {
        key: t(".defer_date_label"),
        value: defer_date,
        action_href: deferred_before_itt_started? ? nil : trainee_deferral_path(data_model.trainee),
        action_text: t(:change),
        action_visually_hidden_text: "date of deferral",
      }
    end

    def trainee_defer_reason_row
      {
        key: t(".defer_reason_label"),
        value: defer_reason,
        action_href: trainee_deferral_reason_path(data_model.trainee),
        action_text: t(:change),
        action_visually_hidden_text: "deferral reason",
      }
    end

  private

    def defer_date
      return t(".deferred_before_itt_started").html_safe if deferred_before_itt_started?

      return t(".itt_started_but_trainee_did_not_start").html_safe if itt_not_yet_started?

      date_for_summary_view(data_model.date)
    end

    def defer_reason
      data_model.defer_reason.presence || t(".no_defer_reason")
    end

    def deferred_before_itt_started?
      starts_course_in_the_future? && itt_not_yet_started?
    end

    def itt_not_yet_started?
      data_model.itt_not_yet_started? || data_model.date.nil?
    end

    def starts_course_in_the_future?
      data_model.trainee.starts_course_in_the_future?
    end

    def trainee_start_date
      date_for_summary_view(data_model.itt_start_date)
    end

    def trainee_started_itt?
      data_model.itt_start_date.is_a?(Date)
    end
  end
end
