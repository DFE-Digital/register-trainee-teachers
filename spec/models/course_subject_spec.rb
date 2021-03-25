# frozen_string_literal: true

require "rails_helper"

describe CourseSubject do
  subject { build(:course_subject) }

  describe "associations" do
    it { is_expected.to belong_to(:course) }
    it { is_expected.to belong_to(:subject) }
  end
end
