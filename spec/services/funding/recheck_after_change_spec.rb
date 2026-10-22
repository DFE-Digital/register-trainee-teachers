# frozen_string_literal: true

require "rails_helper"

module Funding
  describe RecheckAfterChange do
    let(:cycle) { AcademicCycle.current || create(:academic_cycle, :current) }
    let(:mathematics) { create(:allocation_subject, name: AllocationSubjects::MATHEMATICS) }
    let(:trainee) do
      create(:trainee, :pg_teaching_apprenticeship, start_academic_cycle: cycle, course_allocation_subject: mathematics,
                                                    applying_for_grant: true,
                                                    training_initiative: ROUTE_INITIATIVES_ENUMS[:no_initiative],
                                                    progress: Progress.new(course_details: true, funding: true))
    end

    subject(:recheck) { described_class.call(trainee: trainee, changed: :employing_school) }

    def split_funding_by(column)
      %i[relevant unrelated].zip(%i[disadvantaged non_disadvantaged]).each do |degree, school|
        funding_method = create(:funding_method, training_route: trainee.training_route, funding_type: FUNDING_TYPE_ENUMS[:grant], academic_cycle: cycle,
                                                 column => (column == :degree_relevance ? degree : school))
        create(:funding_method_subject, funding_method: funding_method, allocation_subject: mathematics)
      end
    end

    before do
      enable_features(:funding_eligibility_step)
      split_funding_by(:school_disadvantage)
    end

    def progress
      trainee.reload.progress
    end

    it "makes completed funding in progress and records what changed" do
      expect(recheck).to be(true)
      expect(progress.funding).to be(false)
      expect(progress.funding_recheck_changes).to eq([:employing_school])
    end

    it "records a degree change alongside, when the funding depends on the degree too" do
      split_funding_by(:degree_relevance)
      recheck
      described_class.call(trainee: trainee, changed: :degree)

      expect(progress.funding_recheck_changes).to eq(%i[degree employing_school])
    end

    it "records the change for funding that's started but not complete" do
      trainee.update!(progress: Progress.new(course_details: true, funding: false))

      expect(recheck).to be(true)
      expect(progress.funding_recheck_employing_school).to be(true)
    end

    it "does nothing when funding hasn't been started" do
      trainee.update!(applying_for_grant: nil, training_initiative: nil, funding_eligibility: nil,
                      progress: Progress.new(course_details: true, funding: false))

      expect(recheck).to be(false)
      expect(progress.funding_recheck_changes).to be_empty
    end

    it "does nothing for a submitted trainee" do
      trainee.update!(state: :submitted_for_trn)

      expect(recheck).to be(false)
      expect(progress.funding).to be(true)
    end

    it "does nothing without the funding eligibility step" do
      disable_features(:funding_eligibility_step)

      expect(recheck).to be(false)
      expect(progress.funding).to be(true)
    end

    it "doesn't touch the caller's trainee" do
      trainee.first_names = "Unsaved"
      recheck

      expect(trainee.first_names).to eq("Unsaved")
      expect(Trainee.find(trainee.id).first_names).not_to eq("Unsaved")
    end

    context "when the funding doesn't depend on the change" do
      it "leaves the funding alone after a degree change (the funding depends on the school only)" do
        expect(described_class.call(trainee: trainee, changed: :degree)).to be(false)
        expect(progress.funding).to be(true)
        expect(progress.funding_recheck_changes).to be_empty
      end

      it "leaves the funding alone after a school change when nothing is split" do
        FundingMethod.destroy_all

        expect(recheck).to be(false)
        expect(progress.funding).to be(true)
      end
    end

    it "checks the funding again after a degree change when it depends on the degree" do
      split_funding_by(:degree_relevance)

      expect(described_class.call(trainee: trainee, changed: :degree)).to be(true)
      expect(progress.funding_recheck_changes).to eq([:degree])
    end
  end
end
