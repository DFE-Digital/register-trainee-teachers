# frozen_string_literal: true

module Dqt
  class FindRetryJobs < BaseFindJobs
    def sidekiq_class
      Sidekiq::RetrySet
    end
  end
end
