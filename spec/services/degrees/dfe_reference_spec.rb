# frozen_string_literal: true

require "rails_helper"

module Degrees
  describe DfEReference do
    describe ".find_subject" do
      let(:degree_subject) do
        Degrees::DfEReference::SUBJECTS.all.find { |item| item[:hecos_code].present? }
      end

      it "can find the subject by UUID" do
        expect(described_class.find_subject(uuid: degree_subject.id)).to match(degree_subject)
      end

      it "can find the subject by name" do
        expect(described_class.find_subject(name: degree_subject.name)).to match(degree_subject)
      end

      it "can find the subject by hecos_code" do
        expect(described_class.find_subject(hecos_code: degree_subject.hecos_code)).to match(degree_subject)
      end
    end

    describe ".find_type" do
      let(:degree_type) do
        Degrees::DfEReference::TYPES.all.find do |item|
          item[:hesa_itt_code].present? && item[:abbreviation].present?
        end
      end

      it "can find the type by UUID" do
        expect(described_class.find_type(uuid: degree_type.id)).to match(degree_type)
      end

      it "can find the type by name" do
        expect(described_class.find_type(abbreviation: degree_type.name)).to match(degree_type)
      end

      it "can find the type by abbreviation" do
        expect(described_class.find_type(abbreviation: degree_type.abbreviation)).to match(degree_type)
      end

      it "can find the type by HESA code" do
        expect(described_class.find_type(hesa_code: degree_type.hesa_itt_code)).to match(degree_type)
      end
    end

    describe ".find_institution" do
      let(:degree_institution) do
        Degrees::DfEReference::INSTITUTIONS.all.find { |item| item[:hesa_itt_code].present? }
      end

      it "can find the institution by UUID" do
        expect(described_class.find_institution(uuid: degree_institution.id)).to match(degree_institution)
      end

      it "can find the institution by name" do
        expect(described_class.find_institution(name: degree_institution.name)).to match(degree_institution)
      end

      it "can find the institution by HESA code" do
        expect(described_class.find_institution(hesa_code: degree_institution.hesa_itt_code)).to match(degree_institution)
      end
    end

    describe ".find_grade" do
      let(:degree_grade) do
        Degrees::DfEReference::SUPPORTED_GRADES_WITH_OTHER.all.find { |item| item[:hesa_code].present? }
      end

      it "can find the grade by UUID" do
        expect(described_class.find_grade(uuid: degree_grade.id)).to match(degree_grade)
      end

      it "can find the grade by name" do
        expect(described_class.find_grade(name: degree_grade.name)).to match(degree_grade)
      end

      it "can find the grade by HESA code" do
        expect(described_class.find_grade(hesa_code: degree_grade.hesa_code)).to match(degree_grade)
      end
    end
  end
end
