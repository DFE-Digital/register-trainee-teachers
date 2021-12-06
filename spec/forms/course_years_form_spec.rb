# frozen_string_literal: true

require "rails_helper"

describe CourseYearsForm, type: :model do
  let(:params) { {} }

  subject { described_class.new(params) }

  describe "validations" do
    it { is_expected.to validate_inclusion_of(:course_year).in_array(subject.course_years_options.keys) }
  end

  describe "#course_years_options" do
    before do
      allow(Settings).to receive(:current_default_course_year).and_return(2010)
    end

    it "returns course years hash" do
      expect(subject.course_years_options).to eql({
        2011 => "2011 to 2012",
        2010 => "2010 to 2011 (current year)",
        2009 => "2009 to 2010",
      })
    end
  end
end
