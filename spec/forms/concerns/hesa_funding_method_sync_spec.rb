# frozen_string_literal: true

require "rails_helper"

describe HesaFundingMethodSync do
  let(:host_class) do
    Class.new do
      include HesaFundingMethodSync

      attr_accessor :trainee

      def save!
        sync_hesa_funding_method
      end
    end
  end

  let(:instance) { host_class.new.tap { |i| i.trainee = trainee } }

  describe "#save!" do
    context "when the trainee has no hesa_trainee_detail" do
      let(:trainee) { build(:trainee, applying_for_scholarship: true) }

      it "is a no-op" do
        expect { instance.save! }.not_to raise_error
      end
    end

    context "when the trainee has a hesa_trainee_detail" do
      let(:trainee) { create(:trainee, applying_for_scholarship: true) }

      before do
        trainee.create_hesa_trainee_detail!(funding_method: nil)
      end

      it "assigns funding_method in memory using the mapper" do
        expect { instance.save! }
          .to change { trainee.hesa_trainee_detail.funding_method }
          .from(nil)
          .to(Hesa::CodeSets::BursaryLevels::SCHOLARSHIP)
      end

      it "does not persist the change on its own" do
        instance.save!

        expect(trainee.hesa_trainee_detail.reload.funding_method).to be_nil
      end
    end
  end
end
