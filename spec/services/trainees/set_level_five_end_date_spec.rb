# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe SetLevelFiveEndDate do
    let(:start) { Date.new(2026, 9, 1) }
    let(:trainee) do
      create(:trainee, :early_years_teacher_degree_apprenticeship, itt_start_date: start, itt_end_date: nil,
                                                                   study_mode: :full_time, level_five_qualification: true)
    end

    def call(previous_answer: nil)
      described_class.call(trainee:, previous_answer:)
      trainee.reload.itt_end_date
    end

    it "fills in a blank expected end date: 2 years with a level 5 qualification" do
      expect(call).to eq(start + 2.years)
    end

    it "fills in 3 years without one" do
      trainee.update!(level_five_qualification: false)

      expect(call).to eq(start + 3.years)
    end

    it "moves a date it filled in when the answer changes" do
      trainee.update!(itt_end_date: start + 3.years)

      expect(call(previous_answer: false)).to eq(start + 2.years)
    end

    it "keeps a date the provider entered" do
      trainee.update!(itt_end_date: Date.new(2028, 7, 31))

      expect(call(previous_answer: false)).to eq(Date.new(2028, 7, 31))
    end

    it "leaves part-time trainees alone" do
      trainee.update!(study_mode: :part_time)

      expect(call).to be_nil
    end

    it "leaves submitted trainees alone" do
      trainee.update_column(:state, Trainee.states[:submitted_for_trn])

      expect(call).to be_nil
    end
  end
end
