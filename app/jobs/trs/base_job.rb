# frozen_string_literal: true

module Trs
  class BaseJob < ApplicationJob
    sidekiq_options retry: 10
  end
end
