# frozen_string_literal: true

require "rails_helper"

module Funding
  describe PaymentSchedule do
    describe "associations" do
      it { is_expected.to have_many(:rows) }
      it { is_expected.to belong_to(:payable) }
    end
  end
end
