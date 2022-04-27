# frozen_string_literal: true

require "rails_helper"

module Funding
  describe PaymentScheduleRow do
    describe "associations" do
      it { is_expected.to have_many(:amounts) }
      it { is_expected.to belong_to(:payment_schedule) }
    end
  end
end
