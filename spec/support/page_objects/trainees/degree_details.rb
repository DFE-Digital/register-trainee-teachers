module PageObjects
  module Trainees
    class DegreeDetails < PageObjects::Base
      set_url "/trainees/{trainee_id}/degrees/{id}/edit"
    end
  end
end
