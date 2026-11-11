# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe RecheckAfterLevelFiveChange do
    let(:progress) { Progress.new(level_five_declaration: true, course_details: true, funding: true) }
    let(:trainee) do
      create(:trainee, :early_years_teacher_degree_apprenticeship, level_five_qualification: false, progress: progress,
                                                                   funding_eligibility: :eligible, applying_for_grant: true,
                                                                   training_initiative: ROUTE_INITIATIVES_ENUMS[:no_initiative])
    end

    def call(previous_answer: true, funding_started_before: false)
      result = described_class.call(trainee:, previous_answer:, funding_started_before:)
      trainee.reload
      result
    end

    it "sends completed course details back to be confirmed and resets the funding when the answer changes" do
      expect(call).to be(true)
      expect(trainee.progress.course_details).to be(false)
      expect(trainee.progress.course_details_recheck_level_five_declaration).to be(true)
      expect(trainee.progress.funding).to be(false)
      expect(trainee.progress.funding_removed_reason).to eq("level_five_declaration")
      expect(trainee.progress.funding_recheck_changes).to be_empty
    end

    it "works from No to Yes too" do
      trainee.update!(level_five_qualification: true)

      expect(call(previous_answer: false)).to be(true)
      expect(trainee.progress.course_details_recheck_level_five_declaration).to be(true)
      expect(trainee.progress.funding_removed_reason).to eq("level_five_declaration")
    end

    it "clears every funding answer, so the provider starts the funding again" do
      call
      expect(trainee).to have_attributes(funding_eligibility: nil, training_initiative: nil, applying_for_grant: nil,
                                         applying_for_bursary: nil, applying_for_scholarship: nil, bursary_tier: nil)
    end

    it "clears a confirmed longer course, so it's confirmed again against the new usual length" do
      trainee.update!(extended_course_confirmed: true)

      call
      expect(trainee.extended_course_confirmed).to be(false)
    end

    it "does nothing for the first answer" do
      expect(call(previous_answer: nil)).to be(false)
      expect(trainee.progress.course_details).to be(true)
      expect(trainee.progress.funding).to be(true)
      expect(trainee.applying_for_grant).to be(true)
    end

    it "does nothing when the same answer is saved again" do
      expect(call(previous_answer: false)).to be(false)
      expect(trainee.progress.course_details).to be(true)
      expect(trainee.applying_for_grant).to be(true)
    end

    it "shows the level 5 declaration as the reason when moving the end date already removed the funding" do
      RecheckAfterCourseChange.clear_funding(trainee, reason: "course_details")
      trainee.save!

      call(funding_started_before: true)
      expect(trainee.progress.funding_removed_reason).to eq("level_five_declaration")
    end

    context "when the funding hasn't been started" do
      let(:trainee) do
        create(:trainee, :early_years_teacher_degree_apprenticeship, level_five_qualification: false,
                                                                     progress: Progress.new(course_details: true))
      end

      it "leaves the funding alone" do
        call
        expect(trainee.progress.course_details_recheck_level_five_declaration).to be(true)
        expect(trainee.progress.funding_removed_reason).to be_nil
      end
    end

    context "when no course dates have been entered" do
      let(:trainee) do
        create(:trainee, :early_years_teacher_degree_apprenticeship, level_five_qualification: false,
                                                                     itt_start_date: nil, itt_end_date: nil)
      end

      it "has nothing to confirm again" do
        expect(call).to be(false)
        expect(trainee.progress.course_details_recheck_level_five_declaration).to be(false)
      end
    end

    context "when the trainee has been submitted" do
      let(:trainee) do
        create(:trainee, :early_years_teacher_degree_apprenticeship, :submitted_for_trn, level_five_qualification: false, progress: progress,
                                                                                         applying_for_grant: true)
      end

      it "leaves them alone" do
        expect(call).to be(false)
        expect(trainee.progress.course_details).to be(true)
        expect(trainee.applying_for_grant).to be(true)
      end
    end
  end
end
