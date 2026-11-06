# frozen_string_literal: true

require "rails_helper"

# The Level 5 declaration sets the usual length of an EYTDA course (2 or 3
# years). A blank expected end date is filled in from it. Any end date can be
# entered, but a full-time course longer than usual has to be confirmed.
describe CourseDetailsForm, type: :model do
  let(:level_five_qualification) { true }
  let(:trainee) { build(:trainee, :early_years_teacher_degree_apprenticeship, level_five_qualification: level_five_qualification, itt_start_date: nil, itt_end_date: nil) }
  let(:form_store) { class_double(FormStore, get: nil) }
  let(:end_date) { {} }
  let(:confirmed) { {} }
  let(:study_mode) { "full_time" }
  let(:params) { { study_mode: study_mode, start_day: "1", start_month: "9", start_year: "2026" }.merge(end_date).merge(confirmed) }

  subject(:form) { described_class.new(trainee, params: params, store: form_store) }

  before do
    create(:academic_cycle, start_date: Date.new(2026, 8, 1), end_date: Date.new(2027, 7, 31)) unless AcademicCycle.for_year(2026)
    form.valid?
  end

  context "with a level 5 qualification (usually 2 years)" do
    it "fills in a blank expected end date 2 years after the ITT start date" do
      expect(form.errors[:itt_end_date]).to be_empty
      expect(form.itt_end_date).to eq(Date.new(2028, 9, 1))
      expect(form.course_longer_than_usual?).to be(false)
    end

    context "with an expected end date within 2 years" do
      let(:end_date) { { end_day: "31", end_month: "7", end_year: "2028" } }

      it { expect(form.errors).to be_empty }
    end

    context "with an expected end date in the first year" do
      let(:end_date) { { end_day: "1", end_month: "7", end_year: "2027" } }

      it "is allowed: a shorter course needs no declaration" do
        expect(form.errors).to be_empty
      end
    end

    context "with an expected end date more than 2 years after the start" do
      let(:end_date) { { end_day: "1", end_month: "9", end_year: "2029" } }

      it "accepts the date but asks the provider to confirm the longer course" do
        expect(form.errors[:itt_end_date]).to be_empty
        expect(form.course_longer_than_usual?).to be(true)
        expect(form.errors[:extended_course_confirmed]).to eq(["Confirm the course is longer than 2 years"])
        expect(form.course_length_section?).to be(true)
      end

      it "warns rather than shows an error the first time" do
        form.warn_about_course_length
        expect(form.errors[:extended_course_confirmed]).to be_empty
        expect(form).not_to be_valid
      end

      context "when the provider has already seen the warning" do
        let(:confirmed) { { course_length_warning_shown: "1" } }

        it "shows the error" do
          form.warn_about_course_length
          expect(form.errors[:extended_course_confirmed]).to eq(["Confirm the course is longer than 2 years"])
        end
      end

      context "when the provider confirms it" do
        let(:confirmed) { { extended_course_confirmed: "1" } }

        it { expect(form.errors).to be_empty }
      end

      context "when the provider leaves the box unticked" do
        let(:confirmed) { { extended_course_confirmed: "0" } }

        it { expect(form.errors[:extended_course_confirmed]).to be_present }
      end
    end

    context "with an expected end date past the latest year on other routes" do
      let(:end_date) { { end_day: "1", end_month: "9", end_year: (Time.zone.now.year + 10).to_s } }

      it "accepts the date but asks the provider to confirm the longer course" do
        expect(form.errors[:itt_end_date]).to be_empty
        expect(form.course_longer_than_usual?).to be(true)
        expect(form.errors[:extended_course_confirmed]).to eq(["Confirm the course is longer than 2 years"])
      end

      context "when the provider confirms it" do
        let(:confirmed) { { extended_course_confirmed: "1" } }

        it { expect(form.errors).to be_empty }
      end
    end

    context "with a year that isn't 4 digits" do
      let(:end_date) { { end_day: "1", end_month: "9", end_year: "20299" } }
      let(:confirmed) { { extended_course_confirmed: "1" } }

      it { expect(form.errors[:itt_end_date]).to eq(["Enter a valid Expected end date"]) }
    end

    context "part time" do
      let(:study_mode) { "part_time" }
      let(:end_date) { { end_day: "1", end_month: "9", end_year: "2030" } }

      it "needs no declaration" do
        expect(form.errors).to be_empty
        expect(form.course_longer_than_usual?).to be(false)
      end

      context "with an expected end date past the latest year allowed" do
        let(:end_date) { { end_day: "1", end_month: "9", end_year: (Time.zone.now.year + 6).to_s } }

        it "says which year is the latest" do
          expect(form.errors[:itt_end_date]).to eq(["Enter an Expected end date in #{Time.zone.now.year + 5} or earlier"])
          expect(form.errors[:extended_course_confirmed]).to be_empty
        end
      end
    end
  end

  context "without a level 5 qualification (usually 3 years)" do
    let(:level_five_qualification) { false }

    context "with an expected end date within 3 years" do
      let(:end_date) { { end_day: "1", end_month: "7", end_year: "2028" } }

      it { expect(form.errors).to be_empty }
    end

    context "with an expected end date more than 3 years after the start" do
      let(:end_date) { { end_day: "1", end_month: "9", end_year: "2030" } }

      it "asks the provider to confirm the course is longer than 3 years" do
        expect(form.errors[:extended_course_confirmed]).to eq(["Confirm the course is longer than 3 years"])
      end
    end
  end

  context "before the Level 5 declaration is answered" do
    let(:level_five_qualification) { nil }

    it "asks for the expected end date as before" do
      expect(form.errors[:itt_end_date]).to include("Enter an Expected end date")
    end
  end

  describe "saving" do
    let(:form_store) { class_double(FormStore, get: nil, set: nil) }
    let(:trainee) do
      create(:trainee, :early_years_teacher_degree_apprenticeship, level_five_qualification: true,
                                                                   itt_start_date: Date.new(2026, 9, 1), itt_end_date: Date.new(2028, 9, 1))
    end

    context "with a confirmed longer course" do
      let(:end_date) { { end_day: "1", end_month: "9", end_year: "2029" } }
      let(:confirmed) { { extended_course_confirmed: "1" } }

      it "records the declaration" do
        form.save!
        expect(trainee.reload).to have_attributes(itt_end_date: Date.new(2029, 9, 1), extended_course_confirmed: true)
      end
    end

    context "when the course goes back to the usual length" do
      let(:end_date) { { end_day: "1", end_month: "9", end_year: "2028" } }
      let(:confirmed) { { extended_course_confirmed: "1" } }

      it "clears the declaration" do
        form.save!
        expect(trainee.reload.extended_course_confirmed).to be(false)
      end
    end
  end
end
