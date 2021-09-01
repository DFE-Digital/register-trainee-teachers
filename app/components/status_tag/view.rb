# frozen_string_literal: true

class StatusTag::View < GovukComponent::Base
  def initialize(trainee:, classes: "")
    super(classes: classes, html_attributes: {})
    @trainee = trainee
  end

  def status
    {
      submitted_for_trn: "pending trn",
      recommended_for_award: "#{trainee.award_type} recommended",
      awarded: "#{trainee.award_type} awarded",
    }[trainee.state.to_sym] || trainee.state.gsub("_", " ")
  end

private

  attr_accessor :trainee

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
end
