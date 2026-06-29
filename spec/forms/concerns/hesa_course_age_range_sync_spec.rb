# frozen_string_literal: true

require "rails_helper"

describe HesaCourseAgeRangeSync do
  let(:host_class) do
    Class.new do
      include HesaCourseAgeRangeSync

      attr_accessor :trainee

      def save!
        sync_hesa_course_age_range
      end
    end
  end

  let(:instance) { host_class.new.tap { |i| i.trainee = trainee } }

  describe "#save!" do
    context "when the trainee has no hesa_trainee_detail" do
      let(:trainee) { build(:trainee, course_min_age: 11, course_max_age: 16) }

      it "is a no-op" do
        expect { instance.save! }.not_to raise_error
      end
    end

    context "when the trainee has a hesa_trainee_detail" do
      before { trainee.create_hesa_trainee_detail!(course_age_range: existing_code) }

      context "with a range that has a HESA code" do
        let(:trainee) { create(:trainee, course_min_age: 11, course_max_age: 16) }
        let(:existing_code) { nil }

        it "assigns the HESA code for the range in memory using the mapper" do
          expect { instance.save! }
            .to change { trainee.hesa_trainee_detail.course_age_range }
            .from(nil)
            .to("13918")
        end

        it "does not persist the change on its own" do
          instance.save!

          expect(trainee.hesa_trainee_detail.reload.course_age_range).to be_nil
        end
      end

      context "without a HESA code for the range" do
        let(:trainee) { create(:trainee, course_min_age: 7, course_max_age: 16) }
        let(:existing_code) { "13918" }

        it "clears the stored code to nil" do
          expect { instance.save! }
            .to change { trainee.hesa_trainee_detail.course_age_range }
            .from("13918")
            .to(nil)
        end
      end
    end
  end
end
