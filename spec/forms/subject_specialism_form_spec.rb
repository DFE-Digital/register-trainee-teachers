# frozen_string_literal: true

require "rails_helper"

describe SubjectSpecialismForm, type: :model do
  let(:position) { 1 }
  let(:trainee) { build(:trainee, id: 123456) }
  let(:form_store) { class_double(FormStore) }

  subject { described_class.new(trainee, position, params: params, store: form_store) }

  before do
    allow(form_store).to receive(:get).and_return(nil)
    allow(form_store).to receive(:set).and_return(nil)
  end

  describe "validations" do
    let(:params) { {} }

    before { subject.stash_or_save! }

    it "validates the presence of the course subject matching the position" do
      expect(subject.errors[:course_subject_one]).to contain_exactly("Select a specialism")
    end

    context "trainee has existing course subject data" do
      let(:params) { { course_subject_one: "" } }
      let(:trainee) { build(:trainee, id: 123456, course_subject_one: CourseSubjects::ART_AND_DESIGN) }

      it "validates the presence of the course subject matching the position" do
        expect(subject.errors[:course_subject_one]).to contain_exactly("Select a specialism")
      end
    end
  end

  describe "#stash" do
    let(:params) { { course_subject_one: "special" } }

    it "uses FormStore to temporarily save the fields under a key combination of trainee ID and subject_specialism" do
      expect(form_store).to receive(:set).with(trainee.id, :subject_specialism,  subject.fields)
      subject.stash
    end
  end

  describe "#save!" do
    context "course allocation subject changed" do
      let(:trainee) { build(:trainee, :with_funding, :with_course_allocation_subject, id: 123456) }
      let(:course_subject_one) { Dttp::CodeSets::CourseSubjects::MAPPING.keys.sample }
      let(:params) { { course_subject_one: course_subject_one } }

      before do
        create(:subject_specialism, name: course_subject_one)
        subject.save!
      end

      it "clears funding information" do
        expect(trainee.applying_for_bursary).to be_nil
      end
    end
  end
end
