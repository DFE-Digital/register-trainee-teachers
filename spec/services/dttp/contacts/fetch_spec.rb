# frozen_string_literal: true

require "rails_helper"

module Dttp
  module Contacts
    describe Fetch do
      let(:path) { "/contacts(#{dttp_id})?" }

      include_examples "dttp info fetcher", Dttp::Contact
    end
  end
end
