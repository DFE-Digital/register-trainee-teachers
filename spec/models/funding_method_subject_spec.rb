# frozen_string_literal: true

require "rails_helper"

describe FundingMethodSubject do
  subject { create(:funding_method_subject) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:funding_method) }
    it { is_expected.to validate_presence_of(:allocation_subject) }

    it { is_expected.to validate_uniqueness_of(:allocation_subject).scoped_to(:funding_method_id) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:funding_method) }
    it { is_expected.to belong_to(:allocation_subject) }
  end
end
