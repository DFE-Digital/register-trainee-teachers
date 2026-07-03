# frozen_string_literal: true

require "rails_helper"

module ApplyApplications
  describe ConfirmCourseForm, type: :model do
    subject(:form) { described_class.new(trainee, specialisms, params) }

    let(:trainee) { create(:trainee, :with_secondary_course_details, course_age_range:) }
    let(:course_age_range) { [11, 16] }
    let(:specialisms) { trainee.course_subjects }
    let(:params) { {} }

    describe "#save" do
      context "when the trainee has a hesa_trainee_detail" do
        before { trainee.create_hesa_trainee_detail!(course_age_range: existing_code) }

        context "with a range that has a HESA code" do
          let(:existing_code) { nil }

          it "syncs the hesa course_age_range from the trainee's range" do
            expect { form.save }
              .to change { trainee.reload.hesa_trainee_detail.course_age_range }
              .from(nil).to("13918")
          end
        end

        context "without a HESA code for the range" do
          let(:course_age_range) { [11, 18] }
          let(:existing_code) { "13918" }

          it "clears the stored code to nil" do
            expect { form.save }
              .to change { trainee.reload.hesa_trainee_detail.course_age_range }
              .from("13918").to(nil)
          end
        end
      end

      context "when the trainee has no hesa_trainee_detail" do
        it "does not create one" do
          form.save

          expect(trainee.reload.hesa_trainee_detail).to be_nil
        end
      end

      context "when the study mode is updated and the trainee has a hesa_trainee_detail" do
        let(:trainee) do
          create(:trainee, :provider_led_postgrad,
                 course_uuid: SecureRandom.uuid,
                 study_mode: COURSE_STUDY_MODES[:full_time])
        end

        before do
          trainee.create_hesa_trainee_detail!(course_study_mode: "31")
        end

        it "syncs the course_study_mode to the canonical HESA code for the selected study mode" do
          expect { form.save }
            .to change { trainee.hesa_trainee_detail.reload.course_study_mode }
            .from("31").to("01")
        end
      end
    end
  end
end
