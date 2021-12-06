# frozen_string_literal: true

require "rails_helper"

STATES = Trainee.states.keys.map(&:to_sym) - [:draft]

describe TraineeHelper do
  include TraineeHelper

  describe "#trainee_name" do
    let(:trainee) { build(:trainee) }

    context "with middle name" do
      it "returns the full name including middle name" do
        expect(trainee_name(trainee)).to eq("#{trainee.first_names} #{trainee.middle_names} #{trainee.last_name}")
      end
    end

    context "with no middle name" do
      before do
        trainee.middle_names = ""
      end

      it "returns the first name and last name only" do
        expect(trainee_name(trainee)).to eq("#{trainee.first_names} #{trainee.last_name}")
      end
    end
  end

  describe "#view_trainee" do
    subject { view_trainee(trainee) }

    context "with a draft trainee" do
      let(:trainee) { create(:trainee) }

      it "returns the trainee_path" do
        expect(subject).to eq(trainee_review_drafts_path(trainee))
      end
    end

    STATES.each do |state|
      context "with a #{state} trainee" do
        let(:trainee) { create(:trainee, state) }

        it "returns the trainee_path" do
          expect(subject).to eq(trainee_path(trainee))
        end
      end
    end
  end

  describe "#invalid_data_message" do
    let(:trainee) { create(:trainee, :with_invalid_apply_application) }
    let(:degree) { trainee.degrees.first }

    context "with invalid data" do
      it "return the invalid data message" do
        expect(invalid_data_message("institution", degree)).to eq("The trainee entered ‘University of Warwick’, which was not recognised. You need to search for the closest match.")
      end
    end

    context "without invalid data" do
      it "returns nil as no invalid data found" do
        expect(invalid_data_message("subject", degree)).to eq(nil)
      end
    end
  end

  describe "#trainees_page_title" do
    let(:page_size) { 25 }
    # Using an `object_double` here to stub ActiveRecord::Relation passed into
    # the component. We cannot use `instance_double(ActiveRecord::Relation...)`
    # as it lacks the extra methods that Kaminari mixes in (e.g. `total_count`).
    let(:trainees) do
      object_double(
        Trainee.all.page(1),
        total_count: total_count,
        limit_value: page_size,
        current_page: 1,
        total_pages: (total_count.to_f / page_size).ceil,
      )
    end

    subject { trainees_page_title(trainees, total_count) }

    context "when there is one page of trainees" do
      let(:total_count) { page_size }

      it "returns the title containing the total count" do
        expect(subject).to eq "Trainee records (25 records)"
      end
    end

    context "when there is more than one page of trainees" do
      let(:total_count) { page_size + 1 }

      it "returns the title containing the total count and which page you're on" do
        expect(subject).to eq "Trainee records (26 records) - page 1 of 2"
      end
    end

    context "when there are no trainees" do
      let(:total_count) { 0 }

      it "returns the title containing the 0 count" do
        expect(subject).to eq "Trainee records (0 records)"
      end
    end
  end

  describe "#label_for" do
    context "translated label" do
      it "returns translation of attribute and value" do
        expect(label_for("record_completion", "complete")).to eq("Complete")
      end
    end

    context "trainee_start_year label" do
      it "returns value itself, not translation" do
        expect(label_for("trainee_start_year", "2020")).to eq("2020 to 2021")
      end
    end
  end
end
