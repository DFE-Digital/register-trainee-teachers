# frozen_string_literal: true

module PageObjects
  module SystemAdmin
    module Schools
      class Show < PageObjects::Base
        set_url "/system-admin/schools/{id}"
      end
    end
  end
end
