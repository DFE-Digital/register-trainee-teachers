# frozen_string_literal: true

require "rails_helper"

describe ApplyApplication do
  describe "associations" do
    it { is_expected.to belong_to(:provider).optional }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:application) }
  end

  describe "#degrees_invalid_data" do
    let(:apply_application) { create(:apply_application, invalid_data:) }
    let(:invalid_data) { nil }

    subject { apply_application.degrees_invalid_data }

    it { is_expected.to eq({}) }

    context "when invalid degree data exists" do
      let(:invalid_data) { { "degrees" => { "subject" => "Math" } } }

      it { is_expected.to eq({ "subject" => "Math" }) }
    end
  end

  describe "#course" do
    let(:apply_application) { create(:apply_application) }

    subject { apply_application.course }

    it { is_expected.to be_nil }

    context "when the course exists" do
      let!(:course) { create(:course, uuid: ApiStubs::RecruitsApi.course[:course_uuid], provider: apply_application.provider) }

      it { is_expected.to eq(course) }
    end
  end

  describe "#candidate_full_name" do
    subject { apply_application.candidate_full_name }

    context "when candidate name is present" do
      let(:apply_application) { create(:apply_application, :importable, application: JSON.parse(ApiStubs::RecruitsApi.application)) }

      it { is_expected.to eq("Martin Wells") }
    end

    context "when application data is missing" do
      let(:apply_application) { create(:apply_application, :importable, application: { attributes: {} }) }

      it { is_expected.to be_nil }
    end
  end
end
