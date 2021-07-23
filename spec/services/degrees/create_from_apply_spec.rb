# frozen_string_literal: true

require "rails_helper"

module Degrees
  describe CreateFromApply do
    let(:trainee) { create(:trainee, :with_apply_application) }

    subject(:create_from_apply) { described_class.call(trainee: trainee) }

    it "creates a degree against the provided trainee" do
      expect {
        create_from_apply
      }.to change(trainee.degrees, :count).by(1)
    end

    it "updates invalid entries against the ApplyApplication" do
      create_from_apply
      created_degree_slug = trainee.degrees.last.slug
      expect(trainee.apply_application.degrees_invalid_data).to eq({ created_degree_slug => { "institution" => "University of Warwick" } })
    end

    context "with multiple degrees" do
      before do
        trainee.apply_application.application_attributes["qualifications"]["degrees"] << ApiStubs::ApplyApi.uk_degree.transform_keys(&:to_s)
      end

      it "updates invalid entries against the ApplyApplication" do
        create_from_apply
        degree_one_slug, degree_two_slug = trainee.degrees.pluck(:slug)
        expect(trainee.apply_application.degrees_invalid_data).to eq({
          degree_one_slug => { "institution" => "University of Warwick" },
          degree_two_slug => { "institution" => "University of Warwick" },
        })
      end
    end

    context "when the trainee does not have an apply application" do
      let(:trainee) { create(:trainee) }

      it "raises an error" do
        expect {
          create_from_apply
        }.to raise_error(described_class::ApplyApplicationNotFound, "Apply application not found against this trainee")
      end
    end
  end
end
