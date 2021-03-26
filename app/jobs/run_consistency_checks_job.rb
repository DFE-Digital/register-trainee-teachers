class RunConsistencyChecksJob < ApplicationJob
  queue_as :default

  def perform(*args)
    ConsistencyCheck.all.each do | consistency_check |
      Dttp::CheckConsistencyJob.perform_later(cc.id)
    end 
  end
end
