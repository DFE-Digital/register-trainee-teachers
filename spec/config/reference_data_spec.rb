# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Reference data integrity" do
  def load_reference_data(filename)
    YAML.load_file(Rails.root.join("config/reference_data/#{filename}"))["data"]
  end

  describe "institution.yml" do
    let(:data) { load_reference_data("institution.yml") }

    it "has expected entry count" do
      expect(data.count).to eq(335)
    end

    it "has HESA codes zero-padded to 4 digits" do
      codes = data.flat_map { |e| e["hesa_codes"] }.compact.reject(&:empty?)
      expect(codes).to all(match(/^\d{4}$/))
    end

    it "has no duplicate IDs" do
      ids = data.map { |e| e["id"] }
      expect(ids).to eq(ids.uniq)
    end

    it "is sorted by HESA code ascending with empty codes at end" do
      codes = data.map { |e| e["hesa_codes"]&.first.to_s }
      non_empty = codes.reject(&:empty?)
      empty_count = codes.count(&:empty?)

      expect(non_empty).to eq(non_empty.sort_by(&:to_i))
      expect(codes.last(empty_count)).to all(be_empty)
    end
  end

  describe "degree_type.yml" do
    let(:data) { load_reference_data("degree_type.yml") }

    it "has expected entry count" do
      expect(data.count).to eq(81)
    end

    it "has HESA codes zero-padded to 3 digits" do
      codes = data.flat_map { |e| e["hesa_codes"] }.compact.reject(&:empty?)
      expect(codes).to all(match(/^\d{3}$/))
    end

    it "has no duplicate IDs" do
      ids = data.map { |e| e["id"] }
      expect(ids).to eq(ids.uniq)
    end

    it "is sorted by HESA code ascending" do
      codes = data.map { |e| e["hesa_codes"]&.first.to_s }
      expect(codes).to eq(codes.sort_by(&:to_i))
    end
  end

  describe "degree_subject.yml" do
    let(:data) { load_reference_data("degree_subject.yml") }

    it "has expected entry count" do
      expect(data.count).to eq(1094)
    end

    it "has no duplicate IDs" do
      ids = data.map { |e| e["id"] }
      expect(ids).to eq(ids.uniq)
    end

    it "is sorted by HESA code ascending with empty codes at end" do
      codes = data.map { |e| e["hesa_codes"]&.first.to_s }
      non_empty = codes.reject(&:empty?)
      empty_count = codes.count(&:empty?)

      expect(non_empty).to eq(non_empty.sort_by(&:to_i))
      expect(codes.last(empty_count)).to all(be_empty)
    end

  end
end
