# frozen_string_literal: true

require "rails_helper"

describe BursarySubject do
  subject { create(:bursary_subject) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:bursary) }
    it { is_expected.to validate_presence_of(:allocation_subject) }

    it { is_expected.to validate_uniqueness_of(:allocation_subject).scoped_to(:bursary_id) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:bursary) }
    it { is_expected.to belong_to(:allocation_subject) }
  end
end
