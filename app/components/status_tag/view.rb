# frozen_string_literal: true

class StatusTag::View < GovukComponent::Base
  def initialize(trainee:, classes: "", hide_progress_tag: false)
    super(classes: classes, html_attributes: {})
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
    {
      submitted_for_trn: "pending trn",
      recommended_for_award: "#{trainee.award_type} recommended",
      awarded: "#{trainee.award_type} awarded",
    }[trainee.state.to_sym] || trainee.state.gsub("_", " ")
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

    { status: "incomplete", status_colour: "grey", classes: classes.push("govuk-tag--white") }
  end

  def record_state_tag
    { status:, status_colour:, classes: }
  end
end
