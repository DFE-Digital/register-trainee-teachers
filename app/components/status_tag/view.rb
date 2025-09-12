# frozen_string_literal: true

class StatusTag::View < ApplicationComponent
  def initialize(trainee:, hide_progress_tag: false)
    @trainee = trainee
    @hide_progress_tag = hide_progress_tag
  end

  def tags
    [
      record_progress_tag,
      record_state_tag,
    ].compact
  end

  def status
    if %w[recommended_for_award awarded].include?(trainee.state)
      "#{trainee.award_type}_#{trainee.state}"
    else
      trainee.state
    end
  end

private

  attr_accessor :trainee, :hide_progress_tag

  def status_colour
    {
      draft: "grey",
      submitted_for_trn: "turquoise",
      trn_received: "blue",
      recommended_for_award: "purple",
      awarded: "",
      deferred: "yellow",
      withdrawn: "red",
    }[trainee.state.to_sym]
  end

  def default_classes
    %w[trainee-status]
  end

  def record_progress_tag
    return if hide_progress_tag
    return if trainee.draft? || trainee.submission_ready? || !trainee.awaiting_action?

    { status: "incomplete", status_colour: "grey", classes: default_classes + ["govuk-tag--white"] }
  end

  def record_state_tag
    { status: status, status_colour: status_colour, classes: default_classes }
  end
end
