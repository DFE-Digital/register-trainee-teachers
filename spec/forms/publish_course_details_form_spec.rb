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
    it { is_expected.to validate_presence_of(:course_uuid) }
  end

  context "valid course_uuid" do
    let(:route) { TRAINING_ROUTES_FOR_COURSE.keys.sample }
    let(:params) { { course_uuid: SecureRandom.uuid } }
    let(:trainee) { create(:trainee, :submitted_for_trn, route, course_subject_one: nil) }

    describe "#stash" do
      describe "skip itt_end_date validation" do
        it "uses FormStore to temporarily save the fields under a key combination of trainee ID and course_details" do
          expect(form_store).to receive(:set).with(trainee.id, :publish_course_details, params)
          subject.stash
        end
      end
    end

    describe "save!" do
      context "valid form" do
        let(:params) { { course_uuid: course_uuid } }
        let(:course_uuid) { SecureRandom.uuid }
        let(:subject_name) { "Physical education" }
        let(:course_level) { "primary" }
        let(:subject_specialism_form) do
          SubjectSpecialismForm.new(trainee, params: { course_subject_one: subject_name })
        end
        let(:allocation_subject) do
          create(:subject_specialism, name: subject_name).allocation_subject
        end

        before do
          create(:course_with_subjects,
                 uuid: course_uuid,
                 route: route,
                 accredited_body_code: trainee.provider.code,
                 subject_names: [subject_name])

          subject_specialism_form.stash_or_save!
        end

        context "with a pg_teaching_apprenticeship trainee" do
          let(:route) { :pg_teaching_apprenticeship }
          let(:trainee) { build(:trainee, route) }

          it "does not change the trainee's itt start date" do
            expect { subject.save! }.not_to(change { trainee.itt_start_date })
          end
        end
      end
    end
  end

  context "missing course_uuid" do
    describe "#stash" do
      it "returns false and adds an error to the form" do
        expect(subject.stash).to be false
        expect(subject.errors.messages).to eq({ course_uuid: ["Select a course"] })
      end
    end
  end

  describe "manual entry chosen?" do
    context "when course_uuid is NOT_LISTED" do
      it { be_true }
    end

    context "when course_uuid is nil" do
      let(:params) { { course_uuid: "not_listed" } }

      it { be_false }
    end

    context "when course_uuid is something else" do
      let(:params) { { course_uuid: SecureRandom.uuid } }

      it { be_false }
    end
  end
end
