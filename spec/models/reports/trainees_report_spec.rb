# frozen_string_literal: true

require "rails_helper"

describe Reports::TraineesReport, type: :model do
  include FileHelper

  let(:trainee) { create(:trainee, :for_export, course_uuid: create(:course).uuid) }

  subject { described_class.new(output, scope: Trainee.where(id: trainee.id)) }

  describe "#new" do
    it "returns a Reports::TraineesReport" do
      expect(subject).to be_a(Reports::TraineesReport)
    end
  end
end
