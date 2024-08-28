# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  retry_on StandardError, attempts: 10
end
