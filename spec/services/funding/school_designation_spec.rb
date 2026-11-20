# frozen_string_literal: true

require "rails_helper"

describe Funding::SchoolDesignation do
  subject(:school_designation) { described_class.new(trainee, academic_cycle: cycle) }

  let(:cycle) { AcademicCycle.current || create(:academic_cycle, :current) }
  let(:school) { create(:school, name: "Bluemeadow 2 High", urn: "254333") }
  let(:trainee) do
    create(:trainee, :pg_teaching_apprenticeship, start_academic_cycle: cycle, employing_school: nil)
  end

  describe "#answer" do
    it "is unknown before an employing school is added" do
      expect(school_designation.answer).to eq(:unknown)
    end

    it "is disadvantaged when the school is on the list" do
      create(:funding_school_designation, school: school, academic_cycle: cycle, designation: :disadvantaged)
      trainee.update!(employing_school: school)

      expect(school_designation.answer).to eq(:disadvantaged)
    end

    it "is disadvantaged when the school is designated special" do
      create(:funding_school_designation, school: school, academic_cycle: cycle, designation: :special)
      trainee.update!(employing_school: school)

      expect(school_designation.answer).to eq(:disadvantaged)
    end

    it "is non_disadvantaged when the school is not on the list" do
      trainee.update!(employing_school: school)

      expect(school_designation.answer).to eq(:non_disadvantaged)
    end

    it "is unknown when the employing school is not applicable" do
      trainee.update!(employing_school_not_applicable: true)

      expect(school_designation.answer).to eq(:unknown)
    end
  end

  describe "#school_label" do
    it "includes the URN" do
      trainee.update!(employing_school: school)

      expect(school_designation.school_label).to eq("Bluemeadow 2 High (URN 254333)")
    end
  end

  describe "#matches?" do
    let(:disadvantaged_method) { build(:funding_method, school_disadvantage: :disadvantaged) }
    let(:non_disadvantaged_method) { build(:funding_method, school_disadvantage: :non_disadvantaged) }
    let(:unconditioned_method) { build(:funding_method, school_disadvantage: nil) }

    it "matches unconditioned funding for everyone" do
      expect(school_designation.matches?(unconditioned_method)).to be(true)
    end

    it "matches either conditioned value while the school is unknown" do
      expect(school_designation.matches?(disadvantaged_method)).to be(true)
      expect(school_designation.matches?(non_disadvantaged_method)).to be(true)
    end

    it "matches only the disadvantaged value for a listed school" do
      create(:funding_school_designation, school: school, academic_cycle: cycle, designation: :disadvantaged)
      trainee.update!(employing_school: school)

      expect(school_designation.matches?(disadvantaged_method)).to be(true)
      expect(school_designation.matches?(non_disadvantaged_method)).to be(false)
    end
  end
end
