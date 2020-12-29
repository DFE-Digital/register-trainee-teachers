# frozen_string_literal: true

class StatusTag::View < ViewComponent::Base
  def initialize(trainee:)
    @trainee = trainee
  end

private

  attr_accessor :trainee

  def status
    {
      submitted_for_trn: "pending trn",
      recommended_for_qts: "qts recommended",
    }[trainee.state.to_sym] || trainee.state.gsub("_", " ")
  end

  def status_colour
    {
      draft: "grey",
      submitted_for_trn: "turquoise",
      trn_received: "blue",
      recommended_for_qts: "purple",
      qts_awarded: "",
      deferred: "yellow",
      withdrawn: "red",
    }[trainee.state.to_sym]
  end
end
