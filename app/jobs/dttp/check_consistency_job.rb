module Dttp
  class CheckConsistencyJob < ApplicationJob
    queue_as :default

    def perform(consistency_check_id)
      consistency_check = ConsistencyCheck.find(consistency_check_id)
      dttp_contact_updated_date = Dttp::Contacts::Fetch.call(trainee: trainee).updated_at

      # raise some error if the dates conflict with the consistency check
      # raise xyz if consistency_check.updated_at != dttp_contact_updated_date
    end
  end
end
