# frozen_string_literal: true

require "rails_helper"

describe PublishCourseDetailsForm, type: :model do
  let(:params) { {} }
  let(:trainee) { build(:trainee) }
  let(:form_store) { class_double(FormStore) }

  subject { described_class.new(trainee, params: params, store: form_store) }

  before do
    allow(form_store).to receive(:get).and_return(nil)
    allow(form_store).to receive(:set).and_return(nil)
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:course_code) }
  end

  context "valid course_code" do
    let(:route) { TRAINING_ROUTES_FOR_COURSE.keys.sample }
    let(:params) { { course_code: "c0de" } }
    let(:trainee) { create(:trainee, :submitted_for_trn, route, course_subject_one: nil) }

    describe "#stash" do
      describe "skip course_end_date validation" do
        it "uses FormStore to temporarily save the fields under a key combination of trainee ID and course_details" do
          expect(form_store).to receive(:set).with(trainee.id, :publish_course_details, params)
          subject.skip_course_end_date_validation!
          subject.stash
        end
      end

      describe "validate course_end_date" do
        it "uses FormStore to temporarily save the fields under a key combination of trainee ID and course_details" do
          expect(form_store).not_to receive(:set).with(trainee.id, :publish_course_details, params)
          subject.stash
          expect(subject.errors.messages).to eq({ course_end_date: ["can't be blank"] })
        end
      end
    end

    describe "save!" do
      context "valid form" do
        let(:params) { { course_code: course_code } }
        let(:course_code) { "ABC" }
        let(:subject_name) { "Physical education" }
        let(:course_level) { "primary" }
        let(:subject_specialism_form) do
          SubjectSpecialismForm.new(trainee, params: { course_subject_one: subject_name })
        end

        before do
          create(:course_with_subjects,
                 code: course_code,
                 route: route,
                 accredited_body_code: trainee.provider.code,
                 subject_names: [subject_name])

          subject_specialism_form.stash_or_save!
          subject.skip_course_end_date_validation!
        end

        it "updates the trainee with the publish course details" do
          expect { subject.save! }
          .to change { trainee.course_subject_one }.to(subject_name)
          .and change { trainee.course_education_phase }.to(course_level)
        end

        context "with a pg_teaching_apprenticeship trainee" do
          let(:route) { :pg_teaching_apprenticeship }
          let(:trainee) { build(:trainee, route) }

          it "does not change the trainee's course start date" do
            expect { subject.save! }.not_to(change { trainee.course_start_date })
          end
        end
      end
    end
  end

  context "missing course_code" do
    describe "#stash" do
      it "returns false and adds an error to the form" do
        expect(subject.stash).to eq false
        expect(subject.errors.messages).to eq({ course_code: ["Select a course"] })
      end
    end
  end

  describe "manual entry chosen?" do
    context "when course_code is NOT_LISTED" do
      it { be_true }
    end

    context "when course_code is nil" do
      let(:params) { { course_code: "not_listed" } }

      it { be_false }
    end

    context "when course_code is something else" do
      let(:params) { { course_code: "c0de" } }

      it { be_false }
    end
  end
end
