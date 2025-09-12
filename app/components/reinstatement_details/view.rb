# frozen_string_literal: true

module ReinstatementDetails
  class View < ApplicationComponent
    include SummaryHelper

    attr_reader :reinstatement_form, :itt_end_date_form

    delegate :trainee, to: :reinstatement_form
    delegate :itt_end_date, to: :itt_end_date_form

    def initialize(reinstatement_form:, itt_end_date_form:)
      @reinstatement_form = reinstatement_form
      @itt_end_date_form = itt_end_date_form
    end

    def reinstate_date
      deferred_before_starting? ? t(".reinstated_before_starting").html_safe : date_for_summary_view(reinstatement_form.date)
    end

    def deferred_before_starting?
      reinstatement_form.date.nil?
    end
  end
end
