# frozen_string_literal: true

require "rails_helper"

describe HesaDisabilitiesSync do
  let(:host_class) do
    Class.new do
      include HesaDisabilitiesSync

      attr_accessor :trainee

      def save!
        sync_hesa_disabilities
      end
    end
  end

  let(:instance) { host_class.new.tap { |i| i.trainee = trainee } }

  describe "#save!" do
    context "when the trainee has no hesa_trainee_detail" do
      let(:trainee) { build(:trainee, :disabled) }

      it "is a no-op" do
        expect { instance.save! }.not_to raise_error
      end
    end

    context "when the trainee has a hesa_trainee_detail" do
      let(:trainee) { create(:trainee, :disabled) }

      before do
        trainee.disabilities << create(:disability, :learning_difficulty)
        trainee.create_hesa_trainee_detail!(hesa_disabilities: {})
      end

      it "rebuilds hesa_disabilities in memory using the mapper" do
        expect { instance.save! }
          .to change { trainee.hesa_trainee_detail.hesa_disabilities }
          .from({})
          .to("disability1" => "51")
      end

      it "does not persist the change on its own" do
        instance.save!

        expect(trainee.hesa_trainee_detail.reload.hesa_disabilities).to eq({})
      end
    end
  end
end
