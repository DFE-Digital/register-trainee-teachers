# frozen_string_literal: true

module Dqt
  class FindDeadJobs < BaseFindJobs
    def sidekiq_class
      Sidekiq::DeadSet
    end
  end
end
