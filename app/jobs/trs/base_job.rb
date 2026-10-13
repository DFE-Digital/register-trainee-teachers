# frozen_string_literal: true

module Trs
  class BaseJob < ApplicationJob
    retry_on StandardError, wait: :polynomially_longer, attempts: 11
  end
end
