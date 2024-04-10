# frozen_string_literal: true

module PageObjects
  module Trainees
    class Create < PageObjects::Base
      set_url "/trainees/new"

      element :trainee_id_field, "#trainee-provider-trainee-id-field"
      element :continue, "button[type='submit']"
    end
  end
end
