# frozen_string_literal: true

require "rails_helper"

describe RouteDataManager do
  describe "#update_training_route!" do
    subject do
      described_class.new(trainee:).update_training_route!("provider_led_postgrad")
    end

    let(:progress) { Progress.new(course_details: true, funding: true, personal_details: true, placements: true) }

    context "when a trainee selects a new route" do
      let(:trainee) { create(:trainee, :assessment_only) }

      it "changes route" do
        expect { subject }
          .to change { trainee.training_route }
          .from(trainee.training_route).to("provider_led_postgrad")
      end

      context "when a trainee has course details" do
        let(:trainee) { create(:trainee, :assessment_only, :with_primary_course_details, progress:) }

        it "wipes the course details" do
          expect { subject }
            .to change { trainee.course_education_phase }
            .from(trainee.course_education_phase).to(nil)
            .and change { trainee.course_subject_one }
            .from(trainee.course_subject_one).to(nil)
            .and change { trainee.course_age_range }
            .from(trainee.course_age_range).to([])
            .and change { trainee.itt_start_date }
            .from(trainee.itt_start_date).to(nil)
            .and change { trainee.itt_end_date }
            .from(trainee.itt_end_date).to(nil)
            .and change { trainee.study_mode }
            .from(trainee.study_mode).to(nil)
        end

        it "resets the course details progress" do
          expect { subject }
            .to change { trainee.progress.course_details }
            .from(true).to(false)
        end

        it "does not change any other progress" do
          expect { subject }
            .not_to change { trainee.progress.personal_details }
            .from(true)
        end
      end

      context "when the trainee has funding" do
        let(:trainee) { create(:trainee, :assessment_only, :with_funding, :with_tiered_bursary, applying_for_scholarship: true, progress: progress, applying_for_grant: true) }

        it "wipes initiative details" do
          expect { subject }
            .to change { trainee.training_initiative }
            .from(trainee.training_initiative).to(nil)
            .and change { trainee.training_route }
            .from(trainee.training_route).to("provider_led_postgrad")
        end

        it "wipes bursary details and changes route" do
          expect { subject }
            .to change { trainee.applying_for_bursary }
            .from(trainee.applying_for_bursary).to(nil)
            .and change { trainee.applying_for_grant }
            .from(trainee.applying_for_grant).to(nil)
            .and change { trainee.applying_for_scholarship }.to(nil)
            .and change { trainee.bursary_tier }
            .from(trainee.bursary_tier).to(nil)
        end

        it "resets the funding progress" do
          expect { subject }
            .to change { trainee.progress.funding }
            .from(true).to(false)
        end
      end

      context "when a trainee has placements" do
        let(:trainee) { create(:trainee, :school_direct_tuition_fee, :with_placements, progress:) }

        it "wipes the placements details" do
          expect { subject }
            .to change { trainee.placement_detail }
            .from(trainee.placement_detail).to(nil)
            .and change { trainee.placements.count }
            .from(trainee.placements.count).to(0)
        end

        it "resets the placements progress" do
          expect { subject }
            .to change { trainee.progress.placements }
            .from(true).to(false)
        end

        it "does not change any other progress" do
          expect { subject }
            .not_to change { trainee.progress.personal_details }
            .from(true)
        end
      end
    end

    context "when a trainee selects early_years_undergrad route" do
      let(:trainee) { create(:trainee, :assessment_only) }

      subject do
        described_class.new(trainee:).update_training_route!("early_years_undergrad")
      end

      it "sets course_subject_one to early years teaching and age_range to 0-5" do
        expect { subject }
          .to change { trainee.training_route }
          .from(trainee.training_route).to("early_years_undergrad")
        expect(trainee.course_subject_one).to eq(CourseSubjects::EARLY_YEARS_TEACHING)
        expect(trainee.course_age_range).to eq(DfE::ReferenceData::AgeRanges::ZERO_TO_FIVE)
      end
    end

    context "when a trainee selects the same route" do
      before do
        subject
        trainee.reload
      end

      context "when a trainee has publish course details" do
        let(:trainee) { create(:trainee, :with_publish_course_details, :provider_led_postgrad) }

        it "does not clear the course details section of the trainee" do
          expect(trainee.course_uuid).to be_present
          expect(trainee.course_subject_one).to be_present
          expect(trainee.course_age_range).to be_present
          expect(trainee.itt_start_date).to be_present
          expect(trainee.itt_end_date).to be_present
        end
      end

      context "when a trainee has funding" do
        let(:trainee) { create(:trainee, :provider_led_postgrad, :with_funding) }

        it "does not clear the funding section of the trainee" do
          expect(trainee.training_initiative).to be_present
          expect(trainee.applying_for_bursary).to be(true).or be(false)
        end
      end
    end
  end
end
