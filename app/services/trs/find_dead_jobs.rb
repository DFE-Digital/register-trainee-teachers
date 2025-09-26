# frozen_string_literal: true

module Trs
  class FindDeadJobs < BaseFindJobs
    def sidekiq_class
      Sidekiq::DeadSet
    end
  end
end
