# frozen_string_literal: true

require "rails_helper"

module Diversities
  describe DisabilityDetailForm, type: :model do
    let(:trainee) { build(:trainee, :disabled, :diversity_disclosed) }

    subject { described_class.new(trainee) }

    describe "validations" do
      context "disabilities" do
        before do
          subject.valid?
        end

        it "returns an error if its empty" do
          expect(subject.errors[:disability_ids]).to include(
            I18n.t(
              "activemodel.errors.models.diversities/disability_detail_form.attributes.disability_ids.empty_disabilities",
            ),
          )
        end
      end
    end

    describe "#save!" do
      let(:trainee) { create(:trainee, :disabled, :diversity_disclosed) }
      let(:learning_difficulty) { create(:disability, :learning_difficulty) }
      let(:form_store) { class_double(FormStore) }

      subject { described_class.new(trainee, params: { "disability_ids" => [learning_difficulty.id] }, store: form_store) }

      before do
        allow(form_store).to receive(:get).and_return(nil)
        allow(form_store).to receive(:set)
      end

      context "when the trainee has a hesa_trainee_detail" do
        before { trainee.create_hesa_trainee_detail!(hesa_disabilities: {}) }

        it "syncs hesa_trainee_detail.hesa_disabilities via the mapper" do
          subject.save!

          expect(trainee.reload.hesa_trainee_detail.hesa_disabilities).to eq("disability1" => "51")
        end
      end
    end
  end
end
