# frozen_string_literal: true

require "rails_helper"

module SystemAdmin
  describe FundingMethodForm do
    # Funding is added to a future (draft) year; a live/past year is locked.
    let(:academic_cycle) { create(:academic_cycle, next_cycle: true) }
    let(:chemistry) { create(:allocation_subject, name: "Chemistry") }
    let(:physics) { create(:allocation_subject, name: "Physics") }

    let(:valid_params) do
      {
        academic_year: academic_cycle.start_year,
        funding_type: "bursary",
        amount: "29000",
        training_routes: [TRAINING_ROUTE_ENUMS[:provider_led_postgrad], ""],
        allocation_subject_ids: [chemistry.id, physics.id, ""],
      }
    end

    describe "#save! for the Early years tiered bursary" do
      let(:early_years_itt) { create(:allocation_subject, name: AllocationSubjects::EARLY_YEARS_ITT) }
      let(:tiered_params) do
        valid_params.except(:amount).merge(
          allocation_subject_ids: [early_years_itt.id],
          funding_method: "early_years_tiered",
          financial_incentives: "neither",
          training_routes: [TRAINING_ROUTE_ENUMS[:early_years_postgrad]],
          amount_tier_one: "5000", amount_tier_two: "4000", amount_tier_three: "2000",
        )
      end

      it "creates one record per tier, stored with the HESA tier codes" do
        form = described_class.new(tiered_params)

        expect { form.save! }.to change(FundingMethod, :count).by(3)
        expect(form.created_funding_methods.map { |m| [m.funding_method, m.amount, m.training_route] }).to eq([
          ["7", 5_000, TRAINING_ROUTE_ENUMS[:early_years_postgrad]],
          ["8", 4_000, TRAINING_ROUTE_ENUMS[:early_years_postgrad]],
          ["9", 2_000, TRAINING_ROUTE_ENUMS[:early_years_postgrad]],
        ])
        expect(form.created_funding_methods.first.allocation_subjects).to contain_exactly(early_years_itt)
      end

      it "names the missing tier in the error" do
        form = described_class.new(tiered_params.merge(amount_tier_two: ""))

        expect(form).not_to be_valid
        expect(form.errors[:amount_tier_two]).to eq(["Enter the Tier 2 amount"])
      end

      it "blocks a tier that already exists for the year, route and subject" do
        described_class.new(tiered_params).save!

        form = described_class.new(tiered_params)
        expect(form).not_to be_valid
        expect(form.errors[:base].join).to include("Tier 1")
      end
    end

    describe "#save! for the Early years teacher degree apprenticeship" do
      let(:early_years_itt) { create(:allocation_subject, name: AllocationSubjects::EARLY_YEARS_ITT) }
      let(:eytda) { TRAINING_ROUTE_ENUMS[:early_years_teacher_degree_apprenticeship] }
      let(:eytda_params) do
        valid_params.except(:amount).merge(
          funding_type: "grant", funding_method: "E", financial_incentives: "neither",
          training_routes: [eytda], allocation_subject_ids: [early_years_itt.id],
          amount_year_1: "6000", amount_year_2: "6500", amount_year_3: "7000"
        )
      end

      it "creates one record per training year in the cohort's start year" do
        form = described_class.new(eytda_params)

        expect { form.save! }.to change(FundingMethod, :count).by(3)
        expect(form.created_funding_methods.map { |m| [m.training_year, m.amount, m.academic_cycle, m.training_route] }).to eq([
          [1, 6_000, academic_cycle, eytda],
          [2, 6_500, academic_cycle, eytda],
          [3, 7_000, academic_cycle, eytda],
        ])
      end

      context "in 2026 to 2027, live but open to EYTDA funding" do
        around { |example| Timecop.travel(Date.new(2026, 10, 12)) { example.run } }

        let!(:eytda_year) { AcademicCycle.for_year(2026) || create(:academic_cycle, start_date: Date.new(2026, 8, 1), end_date: Date.new(2027, 7, 31)) }

        it "can be added" do
          form = described_class.new(eytda_params.merge(academic_year: 2026))

          expect { form.save! }.to change { eytda_year.funding_methods.count }.by(3)
        end

        it "is the only funding that can be added" do
          form = described_class.new(valid_params.merge(academic_year: 2026))

          expect(form.save!).to be(false)
          expect(form.errors[:academic_year]).to include("For 2026 to 2027, only Early years teacher degree apprenticeship (EYTDA) grants can be added")
        end
      end

      it "must be added on its own" do
        form = described_class.new(eytda_params.merge(training_routes: [eytda, TRAINING_ROUTE_ENUMS[:early_years_salaried]]))

        expect(form).not_to be_valid
        expect(form.errors[:training_routes]).to include("Add Early years teacher degree apprenticeship funding on its own")
      end

      it "names the missing year" do
        form = described_class.new(eytda_params.merge(amount_year_3: ""))

        expect(form).not_to be_valid
        expect(form.errors[:amount_year_3]).to eq(["Enter the Year 3 amount"])
      end

      it "blocks a training year that already exists" do
        described_class.new(eytda_params).save!

        form = described_class.new(eytda_params)
        expect(form).not_to be_valid
        expect(form.errors[:base].join).to include("Year 1")
      end
    end

    describe "subjects for early years routes" do
      let(:early_years_itt) { create(:allocation_subject, name: AllocationSubjects::EARLY_YEARS_ITT) }
      let(:early_years_params) do
        valid_params.merge(funding_type: "grant", training_routes: [TRAINING_ROUTE_ENUMS[:early_years_postgrad]])
      end

      it "saves early years funding against Early years ITT" do
        form = described_class.new(early_years_params.merge(allocation_subject_ids: [early_years_itt.id]))

        expect { form.save! }.to change(FundingMethod, :count).by(1)
      end

      it "rejects other subjects for early years routes" do
        form = described_class.new(early_years_params)

        expect(form).not_to be_valid
        expect(form.errors[:allocation_subject_ids]).to eq(["Select Early years ITT for early years training routes"])
      end

      it "rejects Early years ITT for other routes" do
        form = described_class.new(valid_params.merge(allocation_subject_ids: [early_years_itt.id]))

        expect(form).not_to be_valid
        expect(form.errors[:allocation_subject_ids]).to eq(["Early years ITT is only for early years training routes"])
      end
    end

    describe "#save!" do
      it "creates one FundingMethod per route with the selected subjects" do
        form = described_class.new(valid_params)

        expect { form.save! }.to change(FundingMethod, :count).by(1)

        funding_method = form.created_funding_methods.first
        expect(funding_method).to have_attributes(
          training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad],
          funding_type: "bursary",
          amount: 29_000,
          academic_cycle:,
        )
        expect(funding_method.allocation_subjects).to contain_exactly(chemistry, physics)
      end

      it "creates a FundingMethod per route for a multi-route selection" do
        params = valid_params.merge(training_routes: [
          TRAINING_ROUTE_ENUMS[:provider_led_undergrad],
          TRAINING_ROUTE_ENUMS[:opt_in_undergrad],
        ])

        expect { described_class.new(params).save! }.to change(FundingMethod, :count).by(2)
      end
    end

    describe "validations" do
      it "is invalid without a route" do
        form = described_class.new(valid_params.merge(training_routes: [""]))
        expect(form.save!).to be(false)
        expect(form.errors[:training_routes]).to be_present
      end

      it "is invalid without a subject" do
        form = described_class.new(valid_params.merge(allocation_subject_ids: [""]))
        expect(form.save!).to be(false)
        expect(form.errors[:allocation_subject_ids]).to be_present
      end

      it "is invalid with a negative amount" do
        form = described_class.new(valid_params.merge(amount: "-5"))
        expect(form.save!).to be(false)
        expect(form.errors[:amount]).to be_present
      end

      it "is invalid with an unknown funding type" do
        form = described_class.new(valid_params.merge(funding_type: "nope"))
        expect(form.save!).to be(false)
        expect(form.errors[:funding_type]).to be_present
      end

      it "rejects mixing QTS and EYTS routes in one submission" do
        form = described_class.new(valid_params.merge(
          funding_type: "grant",
          training_routes: [
            TRAINING_ROUTE_ENUMS[:pg_teaching_apprenticeship], # QTS
            TRAINING_ROUTE_ENUMS[:early_years_salaried],        # EYTS
          ],
        ))
        expect(form.save!).to be(false)
        expect(form.errors[:training_routes].join).to match(/QTS and EYTS funding must be added separately/)
      end

      it "allows several routes that share one award type" do
        form = described_class.new(valid_params.merge(
          funding_type: "grant",
          training_routes: [
            TRAINING_ROUTE_ENUMS[:pg_teaching_apprenticeship],  # QTS
            TRAINING_ROUTE_ENUMS[:teacher_degree_apprenticeship], # QTS
          ],
          allocation_subject_ids: [chemistry.id],
        ))
        expect { form.save! }.to change(FundingMethod, :count).by(2)
      end

      it "cannot add funding to a live year" do
        live = AcademicCycle.current || create(:academic_cycle, :current)
        form = described_class.new(valid_params.merge(academic_year: live.start_year))

        expect(form.save!).to be(false)
        # 2026 to 2027 is live but still open to EYTDA funding, so it names that.
        message = live.locked_except_eytda? ? AddFundingStepForm.eytda_only_message(live) : "You cannot add funding to a year that is live or has ended"
        expect(form.errors[:academic_year]).to include(message)
      end

      it "cannot add funding to a past year" do
        past = create(:academic_cycle, previous_cycle: true)
        form = described_class.new(valid_params.merge(academic_year: past.start_year))

        expect(form.save!).to be(false)
        expect(form.errors[:academic_year]).to include("You cannot add funding to a year that is live or has ended")
      end
    end

    describe "duplicate combinations" do
      it "rejects a combination that already exists, regardless of amount" do
        described_class.new(valid_params.merge(allocation_subject_ids: [chemistry.id])).save!

        duplicate = described_class.new(valid_params.merge(amount: "5000", allocation_subject_ids: [chemistry.id]))
        expect(duplicate.save!).to be(false)
        expect(duplicate.errors[:base].join).to match(/Funding already exists/)
      end

      it "allows the same route and type for a different subject" do
        described_class.new(valid_params.merge(allocation_subject_ids: [chemistry.id])).save!

        other_subject = described_class.new(valid_params.merge(allocation_subject_ids: [physics.id]))
        expect { other_subject.save! }.to change(FundingMethod, :count).by(1)
      end

      it "allows the same combination in a different academic year" do
        described_class.new(valid_params.merge(allocation_subject_ids: [chemistry.id])).save!

        other_year = create(:academic_cycle, one_after_next_cycle: true)
        other = described_class.new(valid_params.merge(academic_year: other_year.start_year, allocation_subject_ids: [chemistry.id]))
        expect { other.save! }.to change(FundingMethod, :count).by(1)
      end

      it "allows the same combination with a different degree relevance" do
        described_class.new(valid_params.merge(allocation_subject_ids: [chemistry.id])).save! # degree_relevance nil

        split = described_class.new(valid_params.merge(
          financial_incentives: "degree_relevancy", amount_relevant: "29000", amount_unrelated: "25000", amount_unrelated_available: "yes",
          allocation_subject_ids: [chemistry.id],
        ))
        expect { split.save! }.to change(FundingMethod, :count).by(2)
      end
    end
  end
end
