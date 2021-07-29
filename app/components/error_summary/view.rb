# frozen_string_literal: true

class ErrorSummary::View < GovukComponent::Base
  renders_one :header

  def initialize(has_errors: false)
    @has_errors = has_errors
  end

  def render?
    has_errors
  end

private

  attr_reader :has_errors
end
