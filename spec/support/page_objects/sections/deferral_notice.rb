# frozen_string_literal: true

require_relative "base"

module PageObjects
  module Sections
    class DeferralNotice < PageObjects::Sections::Base
      element :text, ".deferral-notice_text"
      element :link, ".deferral-notice_link"
    end
  end
end
