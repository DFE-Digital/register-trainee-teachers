# frozen_string_literal: true

module ThrottleRequests
  extend ActiveSupport::Concern
  include ActionView::Helpers::DateHelper

  attr_reader :attempts, :last_attempt, :session

  included do
    validate :cool_down?
  end

  def initialize(session:)
    @session = session
    @attempts = session[attempts_key] = session[attempts_key] || 0
    @last_attempt = session[last_attempt_key] = session[last_attempt_key] || Time.zone.now
  end

private

  def cool_down?
    # Add error message if the user has not yet reached their
    # cool off time.
    if Time.zone.now < (last_attempt + cool_down_time)
      raise_throttle_error
    # Otherwise incement their attempts and reset the last attempt
    # if they submitted a code
    else
      session[attempts_key] += 1
      session[last_attempt_key] = Time.zone.now
    end
  end

  def cool_down_message
    @cool_down_message ||= "Please wait #{time_left} before trying again"
  end

  # increase cool off then default to 1 hour
  def cool_down_time
    @cool_down_time ||= ([0, 0, 0, 0, 0, 60, 300, 600][attempts] || 3600).seconds
  end

  def time_left
    @time_left ||=  time_ago_in_words(((last_attempt + cool_down_time) - Time.zone.now).seconds.from_now)
  end

  def attempts_key
    @attempts_key ||= :"#{self.class.to_s.underscore}_attempts"
  end

  def last_attempt_key
    @last_attempt_key ||= :"#{self.class.to_s.underscore}_last_attempt"
  end
end
