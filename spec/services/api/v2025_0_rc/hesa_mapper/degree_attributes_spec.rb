# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V20250Rc::HesaMapper::DegreeAttributes do
  let(:params) do
    {
      country: "GB",
      grade: "01",
      uk_degree: "400",
      subject: "100485",
      institution: institution_code,
      graduation_year: "2003-06-01",
    }
  end

  describe "#call" do
    context "when institution is Institute of Education (0133)" do
      let(:institution_code) { "0133" }

      it "maps institution to University College London" do
        result = described_class.call(params)

        expect(result[:institution]).to eq("University College London")
      end
    end

    context "when institution is not Institute of Education" do
      let(:institution_code) { "0149" }

      it "does not remap the institution" do
        result = described_class.call(params)

        expect(result[:institution]).to eq("University College London")
      end
    end

    context "when institution is nil" do
      let(:institution_code) { nil }

      it "handles nil institution gracefully" do
        result = described_class.call(params)

        expect(result[:institution]).to be_nil
      end
    end

    context "when grade is Pass without honours (09)" do
      let(:institution_code) { "0149" }
      let(:params) do
        {
          country: "GB",
          grade: "09",
          uk_degree: "400",
          subject: "100485",
          institution: institution_code,
          graduation_year: "2003-06-01",
        }
      end

      it "maps grade to nearest equivalent grade" do
        result = described_class.call(params)

        expect(result[:grade]).to be_present
      end
    end
  end
end
