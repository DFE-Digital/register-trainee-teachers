# frozen_string_literal: true

module Trs
  class FindRetryJobs < BaseFindJobs
    def sidekiq_class
      Sidekiq::RetrySet
    end
  end
end
