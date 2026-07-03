# frozen_string_literal: true

require "rails_helper"

describe HesaCourseStudyModeSync do
  let(:host_class) do
    Class.new do
      include HesaCourseStudyModeSync

      attr_accessor :trainee

      def save!
        sync_hesa_course_study_mode
      end
    end
  end

  let(:instance) { host_class.new.tap { |i| i.trainee = trainee } }

  describe "#save!" do
    context "when the trainee has no hesa_trainee_detail" do
      let(:trainee) { build(:trainee, study_mode: "full_time") }

      it "is a no-op" do
        expect { instance.save! }.not_to raise_error
      end
    end

    context "when the trainee has a hesa_trainee_detail" do
      let(:trainee) { create(:trainee, study_mode: "part_time") }

      before do
        trainee.create_hesa_trainee_detail!(course_study_mode: "01")
      end

      it "assigns the canonical course_study_mode in memory using the mapper" do
        expect { instance.save! }
          .to change { trainee.hesa_trainee_detail.course_study_mode }
          .from("01")
          .to("31")
      end

      it "does not persist the change on its own" do
        instance.save!

        expect(trainee.hesa_trainee_detail.reload.course_study_mode).to eq("01")
      end
    end
  end
end
