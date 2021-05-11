# frozen_string_literal: true

require "rails_helper"

module Degrees
  describe CreateFromApply do
    let(:apply_application) { create(:apply_application) }
    let(:degree_attributes) { ApiStubs::ApplyApi.uk_degree.as_json }

    let(:common_attributes) do
      {
        subject: degree_attributes["subject"],
        graduation_year: degree_attributes["award_year"].to_i,
      }
    end

    let(:uk_degree_attributes) do
      {
        locale_code: "uk",
        uk_degree: degree_attributes["qualification_type"],
        institution: degree_attributes["institution_details"],
        grade: degree_attributes["grade"],
      }
    end

    let(:non_uk_degree_attributes) do
      {
        locale_code: "non_uk",
        non_uk_degree: degree_attributes["comparable_uk_degree"],
        country: "St Kitts and Nevis",
      }
    end

    subject { described_class.call(attributes: degree_attributes) }

    it { is_expected.to be_a_new(Degree) }
    it { is_expected.to have_attributes(common_attributes) }

    context "with a uk degree" do
      it { is_expected.to have_attributes(uk_degree_attributes) }
    end

    context "with a non-uk degree" do
      let(:degree_attributes) { ApiStubs::ApplyApi.non_uk_degree.as_json }

      it { is_expected.to have_attributes(non_uk_degree_attributes) }
    end
  end
end
