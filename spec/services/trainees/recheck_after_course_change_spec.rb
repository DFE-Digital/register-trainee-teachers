# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe RecheckAfterCourseChange do
    let(:cycle) { AcademicCycle.current || create(:academic_cycle, :current) }
    let(:mathematics) { create(:allocation_subject, name: AllocationSubjects::MATHEMATICS) }
    let(:route) { :pg_teaching_apprenticeship }
    let(:funding) { { funding_eligibility: :eligible, training_initiative: ROUTE_INITIATIVES_ENUMS[:no_initiative], applying_for_grant: true } }
    let(:progress) { Progress.new(course_details: true, schools: true, funding: true) }
    let!(:trainee) do
      create(:trainee, route, :with_valid_itt_start_date, :with_employing_school, course_allocation_subject: mathematics,
                                                                                  study_mode: "full_time", progress: progress, **funding)
    end

    before { enable_features(:funding_eligibility_step) }

    def saved_progress
      trainee.reload.progress
    end

    it "removes the funding and makes the schools in progress after a course details change" do
      trainee.update!(study_mode: "part_time")

      expect(saved_progress).to have_attributes(funding: false, funding_removed_reason: "course_details",
                                                funding_recheck_course_details: false,
                                                schools: false, schools_recheck_course_details: true)
    end

    it "counts a start date in another academic year" do
      next_cycle = create(:academic_cycle, start_date: cycle.start_date + 1.year, end_date: cycle.end_date + 1.year)
      trainee.update!(itt_start_date: next_cycle.start_date + 1.day)

      expect(trainee.reload.start_academic_cycle).to eq(next_cycle)
      expect(saved_progress.funding_removed_reason).to eq("course_details")
    end

    it "clears every funding answer, so the provider starts the funding again" do
      trainee.update!(study_mode: "part_time")

      expect(trainee.reload).to have_attributes(funding_eligibility: nil, training_initiative: nil, applying_for_grant: nil,
                                                applying_for_bursary: nil, applying_for_scholarship: nil, bursary_tier: nil)
    end

    it "works out again whether the trainee is ready to submit" do
      trainee.update!(study_mode: "part_time")

      expect(trainee.reload.submission_ready).to be(false)
    end

    context "on a route without an employing school" do
      let(:route) { :provider_led_postgrad }
      let(:funding) { { funding_eligibility: :eligible, training_initiative: ROUTE_INITIATIVES_ENUMS[:no_initiative], applying_for_bursary: true } }

      it "removes only the funding" do
        trainee.update!(study_mode: "part_time")

        expect(saved_progress).to have_attributes(funding_removed_reason: "course_details", schools: true, schools_recheck_course_details: false)
        expect(trainee.reload.applying_for_bursary).to be_nil
      end
    end

    it "records why the funding was removed when the course subject changed" do
      trainee.assign_attributes(course_allocation_subject: create(:allocation_subject, name: AllocationSubjects::PHYSICS),
                                training_initiative: nil, applying_for_grant: nil)
      trainee.save!

      expect(saved_progress).to have_attributes(funding: false, funding_removed_reason: "subject", funding_recheck_course_details: false)
    end

    it "records why the funding was removed when the route changed" do
      RouteDataManager.new(trainee:).update_training_route!(TRAINING_ROUTE_ENUMS[:school_direct_salaried])
      trainee.save!

      expect(saved_progress).to have_attributes(funding: false, funding_removed_reason: "route")
    end

    context "when the funding hasn't been started" do
      let(:funding) { {} }
      let(:progress) { Progress.new(course_details: true, schools: true) }

      it "checks only the employing school again" do
        trainee.update!(study_mode: "part_time")

        expect(saved_progress).to have_attributes(funding_removed_reason: nil, schools_recheck_course_details: true)
      end
    end

    it "doesn't count entering a course detail for the first time" do
      trainee.update_column(:study_mode, nil)
      trainee.reload.update!(study_mode: "full_time")

      expect(saved_progress).to have_attributes(funding: true, schools: true)
    end

    it "doesn't count other changes" do
      trainee.update!(first_names: "Changed")

      expect(saved_progress).to have_attributes(funding: true, schools: true)
    end

    it "doesn't change a submitted trainee" do
      trainee.update_column(:state, Trainee.states[:submitted_for_trn])
      trainee.reload.update!(study_mode: "part_time")

      expect(saved_progress).to have_attributes(funding: true, schools: true)
    end

    it "doesn't change anything without the funding eligibility step" do
      disable_features(:funding_eligibility_step)
      trainee.update!(study_mode: "part_time")

      expect(saved_progress).to have_attributes(funding: true, schools: true)
    end
  end
end
