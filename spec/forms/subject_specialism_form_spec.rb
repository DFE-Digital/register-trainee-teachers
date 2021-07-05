# frozen_string_literal: true

require "rails_helper"

describe SubjectSpecialismForm, type: :model do
  let(:params) { {} }
  let(:trainee) { build(:trainee, id: 123456) }
  let(:form_store) { class_double(FormStore) }

  subject { described_class.new(trainee, position, params: params, store: form_store) }

  before do
    allow(form_store).to receive(:get).and_return(nil)
  end

  describe "validations" do
    let(:position) { 1 }

    it "validates the presence of the course subject matching the position"  do
      expect(subject.valid?).to eq false
      expect(subject.errors[:specialism_1]).to contain_exactly("Select a specialism")
    end
  end

  describe "#stash" do
    let(:position) { 1 }
    let(:params) { { specialism_1: "special" } }

    it "uses FormStore to temporarily save the fields under a key combination of trainee ID and subject_specialism" do
      expect(form_store).to receive(:set).with(trainee.id, :subject_specialism,  subject.fields)
      subject.stash
    end
  end

  describe "#save!" do
    let(:position) { nil }
    let(:stashed_fields) do
      {
        specialism_1: "pizza",
        specialism_2: "oragami",
      }
    end

    before do
      allow(form_store).to receive(:get).and_return(stashed_fields)
      allow(form_store).to receive(:set).with(trainee.id, :subject_specialism, nil)
    end

    it "takes any data from the form store and saves it to the database" do
      expect { subject.save! }.to change(trainee, :course_subject_one).to("pizza")
        .and change(trainee, :course_subject_two).to("oragami")
    end
  end
end
