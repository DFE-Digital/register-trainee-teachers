# frozen_string_literal: true

module PageObjects
  module Organisations
    class Index < PageObjects::Base
      set_url "/organisations"
      elements :provider_links, ".provider-link"
      elements :lead_school_links, ".lead-school-link"
    end
  end
end
