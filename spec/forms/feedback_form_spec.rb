# frozen_string_literal: true

require "rails_helper"

describe FeedbackForm, type: :model do
  let(:store_id) { "test-session-id" }

  let(:params) do
    {
      satisfaction_level: "satisfied",
      improvement_suggestion: "More documentation would be helpful",
      name: "Jane Smith",
      email: "user@example.com",
    }
  end

  subject { described_class.new(store_id, params: params) }

  before do
    allow(FormStore).to receive(:get).with(store_id, :feedback).and_return(nil)
  end

  describe "validations" do
    it { is_expected.to be_valid }

    context "when satisfaction_level is blank" do
      before { subject.satisfaction_level = nil }

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors[:satisfaction_level]).to include("Select how you feel about this service")
      end
    end

    context "when satisfaction_level is not in the allowed values" do
      before { subject.satisfaction_level = "invalid" }

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors[:satisfaction_level]).to include("Select how you feel about this service")
      end
    end

    context "when improvement_suggestion is blank" do
      before { subject.improvement_suggestion = nil }

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors[:improvement_suggestion]).to include("Enter details about how we could improve this service")
      end
    end

    context "when name is blank" do
      before { subject.name = nil }

      it "is valid" do
        expect(subject).to be_valid
      end
    end

    context "when email is blank" do
      before { subject.email = nil }

      it "is valid" do
        expect(subject).to be_valid
      end
    end
  end

  describe "#stash" do
    it "uses FormStore to temporarily save the fields" do
      expected_fields = {
        satisfaction_level: "satisfied",
        improvement_suggestion: "More documentation would be helpful",
        name: "Jane Smith",
        email: "user@example.com",
      }

      expect(FormStore).to receive(:set).with(store_id, :feedback, expected_fields)

      subject.stash
    end

    context "when invalid" do
      before { subject.satisfaction_level = nil }

      it "returns false" do
        expect(subject.stash).to be false
      end
    end
  end

  describe "#save" do
    before do
      allow(FormStore).to receive(:set)
    end

    it "creates a Feedback record" do
      expect { subject.save }.to change(Feedback, :count).by(1)
    end

    it "saves the correct attributes" do
      subject.save
      feedback = Feedback.last

      expect(feedback.satisfaction_level).to eq("satisfied")
      expect(feedback.improvement_suggestion).to eq("More documentation would be helpful")
      expect(feedback.name).to eq("Jane Smith")
      expect(feedback.email).to eq("user@example.com")
    end

    it "clears the stash" do
      expect(FormStore).to receive(:set).with(store_id, :feedback, nil)

      subject.save
    end

    context "when invalid" do
      before { subject.satisfaction_level = nil }

      it "returns false and does not create a record" do
        expect { subject.save }.not_to change(Feedback, :count)
        expect(subject.save).to be false
      end
    end
  end

  describe "#stashed?" do
    context "when there is data in the store" do
      before do
        allow(FormStore).to receive(:get).with(store_id, :feedback).and_return(params.stringify_keys)
      end

      it "returns true" do
        expect(subject).to be_stashed
      end
    end

    context "when there is no data in the store" do
      it "returns false" do
        expect(subject).not_to be_stashed
      end
    end
  end

  describe "#satisfaction_level_text" do
    it "returns the human-readable label" do
      expect(subject.satisfaction_level_text).to eq("Satisfied")
    end

    context "when satisfaction_level is blank" do
      before { subject.satisfaction_level = nil }

      it "returns nil" do
        expect(subject.satisfaction_level_text).to be_nil
      end
    end
  end

  describe "#compute_fields" do
    context "when store has data" do
      before do
        allow(FormStore).to receive(:get).with(store_id, :feedback).and_return(
          { "satisfaction_level" => "very_satisfied" },
        )
      end

      it "merges store data with params, with params taking precedence" do
        form = described_class.new(store_id, params: { satisfaction_level: "dissatisfied", improvement_suggestion: "Needs work" })
        expect(form.satisfaction_level).to eq("dissatisfied")
      end

      it "uses store data when no params provided" do
        form = described_class.new(store_id, params: {})
        expect(form.satisfaction_level).to eq("very_satisfied")
      end
    end
  end
end
