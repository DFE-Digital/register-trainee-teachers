# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReferenceData::Type do
  subject(:type) { ReferenceData::Loader.instance.find("study_mode") }

  describe "#name" do
    it "has the correct name value" do
      expect(type.name).to eq("study_mode")
    end
  end

  describe "#display_name" do
    it "has the correct display_name value" do
      expect(type.display_name).to eq("Study mode")
    end
  end

  describe "#values" do
    it "has the correct values" do
      expect(type.values).to include(
        an_object_having_attributes(id: 0, name: "part_time", display_name: "Part-time"),
        an_object_having_attributes(id: 1, name: "full_time", display_name: "Full-time"),
      )
    end
  end

  describe "#find" do
    it "can lookup reference data value by `id`" do
      part_time_value = type.find(0)
      expect(part_time_value).to be_present
      expect(part_time_value).to be_a(ReferenceData::Value)
    end

    it "can lookup reference data value by `id` as a string" do
      part_time_value = type.find("0")
      expect(part_time_value).to be_present
      expect(part_time_value).to be_a(ReferenceData::Value)
    end

    it "can lookup reference data value by name as a symbol" do
      part_time_value = type.find(:part_time)
      expect(part_time_value).to be_present
      expect(part_time_value).to be_a(ReferenceData::Value)
    end

    it "can lookup reference data value by name as a string" do
      part_time_value = type.find("full_time")
      expect(part_time_value).to be_present
      expect(part_time_value).to be_a(ReferenceData::Value)
    end

    it "returns nil for unknown reference data values" do
      expect(type.find("over_time")).to be_nil
    end
  end

  describe "#ids" do
    it "returns all ids as strings" do
      expect(type.ids).to contain_exactly("0", "1")
    end
  end

  describe "#names" do
    subject(:type) { ReferenceData::Loader.instance.find("training_route") }

    context "unfiltered" do
      it "returns all names as strings" do
        expect(type.names).to contain_exactly(
          "assessment_only",
          "provider_led_postgrad",
          "early_years_undergrad",
          "school_direct_tuition_fee",
          "school_direct_salaried",
          "pg_teaching_apprenticeship",
          "early_years_assessment_only",
          "early_years_salaried",
          "early_years_postgrad",
          "provider_led_undergrad",
          "opt_in_undergrad",
          "hpitt_postgrad",
          "iqts",
          "teacher_degree_apprenticeship",
        )
      end
    end

    context "filtered by year" do
      it "returns available names as strings" do
        expect(type.names(year: 2021)).to contain_exactly(
          "assessment_only",
          "early_years_undergrad",
          "school_direct_tuition_fee",
          "school_direct_salaried",
          "pg_teaching_apprenticeship",
          "early_years_assessment_only",
          "early_years_salaried",
          "early_years_postgrad",
          "provider_led_undergrad",
          "opt_in_undergrad",
          "hpitt_postgrad",
          "iqts",
          "teacher_degree_apprenticeship",
        )
      end
    end
  end

  describe "#hesa_codes" do
    subject(:type) { ReferenceData::Loader.instance.find("training_route") }

    it "returns all HESA codes as strings" do
      expect(type.hesa_codes).to contain_exactly("02", "03", "09", "10", "11", "12", "14")
    end

    context "filtered by year" do
      it "returns available hesa codes only" do
        expect(type.hesa_codes(year: 2021)).to contain_exactly("02", "03", "09", "10", "11", "14")
      end
    end
  end

  describe "#find_by_hesa_code" do
    it "can lookup reference data value by HESA code" do
      part_time_value = type.find_by_hesa_code("31")
      expect(part_time_value).to be_present
      expect(part_time_value).to be_a(ReferenceData::Value)
    end

    it "can lookup reference data value by alternate HESA code" do
      part_time_value = type.find_by_hesa_code("64")
      expect(part_time_value).to be_present
      expect(part_time_value).to be_a(ReferenceData::Value)
    end

    it "returns nil for unknown HESA codes" do
      expect(type.find_by_hesa_code("99")).to be_nil
    end
  end

  describe "#method_missing" do
    it "responds to dynamic finders for name" do
      full_time_value = type.full_time
      expect(full_time_value).to be_present
      expect(full_time_value).to be_a(ReferenceData::Value)
    end

    it "returns nil for unknown dynamic finders" do
      expect { type.over_time }.to raise_error(NoMethodError)
    end
  end
end
