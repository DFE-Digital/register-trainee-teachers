# frozen_string_literal: true

require "rails_helper"

describe TraineeHelper do
  include TraineeHelper

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

  describe "#view_trainee" do
    STATES = Trainee.states.keys.map(&:to_sym) - [:draft]
    subject { view_trainee(trainee) }

    context "with a draft trainee" do
      let(:trainee) { create(:trainee) }
      it "returns the trainee_path" do
        expect(subject).to eq(review_draft_trainee_path(trainee))
      end
    end

    STATES.each do |state|
      context "with a #{state} trainee" do
        let(:trainee) { create(:trainee, state) }
        it "returns the trainee_path" do
          expect(subject).to eq(trainee_path(trainee))
        end
      end
    end
  end
end
