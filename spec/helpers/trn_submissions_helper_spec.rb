# frozen_string_literal: true

require "rails_helper"

describe TrnSubmissionsHelper do
  include TrnSubmissionsHelper

  describe "#trainee_name" do
    let(:trainee) { build(:trainee) }

    context "with middle name" do
      it "returns the full name including middle name" do
        expect(trainee_name(trainee)).to eq("#{trainee.first_names} #{trainee.middle_names} #{trainee.last_name}")
      end
    end

    context "with no middle name" do
      before do
        trainee.middle_names = ""
      end

      it "returns the first name and last name only" do
        expect(trainee_name(trainee)).to eq("#{trainee.first_names} #{trainee.last_name}")
      end
    end
  end
end
