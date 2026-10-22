# frozen_string_literal: true

require "rails_helper"

module SystemAdmin
  describe FundingSchoolDesignationForm do
    let(:cycle) { create(:academic_cycle, next_cycle: true) }
    let(:school) { create(:school, urn: "123456") }

    let(:valid_params) { { academic_year: cycle.start_year, designation: "disadvantaged", urn: school.urn } }

    it "resolves the school and creates a designation" do
      school
      form = described_class.new(valid_params)
      expect(form.valid?).to be(true)
      expect(form.school).to eq(school)
      expect { form.save! }.to change(FundingSchoolDesignation, :count).by(1)
    end

    it "is invalid with a badly formatted URN" do
      form = described_class.new(valid_params.merge(urn: "12"))
      expect(form.valid?).to be(false)
      expect(form.errors[:urn].join).to match(/valid 6-digit URN/)
    end

    it "is invalid when the URN is not a school in Register" do
      form = described_class.new(valid_params.merge(urn: "654321"))
      expect(form.valid?).to be(false)
      expect(form.errors[:urn].join).to match(/No school with URN/)
    end

    it "is invalid for a closed school" do
      closed = create(:school, :closed, urn: "222222")
      form = described_class.new(valid_params.merge(urn: closed.urn))
      expect(form.valid?).to be(false)
      expect(form.errors[:urn].join).to match(/is closed/)
    end

    it "is invalid for an administrative URN" do
      form = described_class.new(valid_params.merge(urn: School::NOT_APPLICABLE_SCHOOL_URNS.first))
      expect(form.valid?).to be(false)
      expect(form.errors[:urn].join).to match(/administrative code/)
    end

    it "is invalid when the school is already designated for the year" do
      create(:funding_school_designation, school:, academic_cycle: cycle)
      form = described_class.new(valid_params)
      expect(form.valid?).to be(false)
      expect(form.errors[:urn].join).to match(/already on the list/)
    end

    it "is invalid for a live year" do
      live = AcademicCycle.current || create(:academic_cycle, :current)
      form = described_class.new(valid_params.merge(academic_year: live.start_year))
      expect(form.valid?).to be(false)
      expect(form.errors[:academic_year].join).to match(/live or has ended/)
    end

    it "requires a designation" do
      form = described_class.new(valid_params.merge(designation: ""))
      expect(form.valid?).to be(false)
      expect(form.errors[:designation]).to be_present
    end
  end
end
