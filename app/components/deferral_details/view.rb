# frozen_string_literal: true

module DeferralDetails
  class View < GovukComponent::Base
    include SummaryHelper

    attr_reader :data_model

    def initialize(data_model)
      @data_model = data_model
    end

    def rows
      [
        trainee_start_date_row,
        deferral_date_row,
      ].compact
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
        action_href: deferred_before_starting? ? nil : trainee_deferral_path(data_model.trainee),
        action_text: t(:change),
        action_visually_hidden_text: "date of deferral",
      }
    end

  private

    def defer_date
      deferred_before_starting? ? t(".deferred_before_starting").html_safe : date_for_summary_view(data_model.date)
    end

    def deferred_before_starting?
      data_model.itt_not_yet_started? || data_model.date.nil?
    end

    def trainee_start_date
      date_for_summary_view(data_model.itt_start_date)
    end

    def trainee_started_itt?
      data_model.itt_start_date.is_a?(Date)
    end
  end
end
