# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe MapDisabilitiesToHesa do
    subject(:hesa_disabilities) { described_class.call(trainee:) }

    context "when the trainee is disabled" do
      let(:trainee) { create(:trainee, :disabled) }

      context "with a single selected disability" do
        before { trainee.disabilities << create(:disability, :learning_difficulty) }

        it "maps the disability to its HESA code" do
          expect(hesa_disabilities).to eq("disability1" => "51")
        end
      end

      context "with multiple selected disabilities" do
        before do
          trainee.disabilities << create(:disability, :learning_difficulty)
          trainee.disabilities << create(:disability, :blind)
        end

        it "maps each disability to its HESA code with contiguous keys" do
          expect(hesa_disabilities.keys).to eq(%w[disability1 disability2])
          expect(hesa_disabilities.values).to match_array(%w[51 58])
        end
      end

      context "with a disability that is not listed" do
        before { trainee.disabilities << create(:disability, :other) }

        it "maps it to the 'not listed' HESA code" do
          expect(hesa_disabilities).to eq("disability1" => "96")
        end
      end

      context "when the stored codes include a disability that is no longer selected" do
        before do
          trainee.disabilities << create(:disability, :blind)
          trainee.create_hesa_trainee_detail!(hesa_disabilities: { "disability1" => "51", "disability2" => "58" })
        end

        it "drops the deselected code and renumbers contiguously" do
          expect(hesa_disabilities).to eq("disability1" => "58")
        end
      end

      context "when the stored code already maps to a selected disability" do
        before do
          trainee.disabilities << create(:disability, :learning_difficulty)
          trainee.create_hesa_trainee_detail!(hesa_disabilities: { "disability1" => "51" })
        end

        it "preserves the existing code" do
          expect(hesa_disabilities).to eq("disability1" => "51")
        end
      end
    end

    context "when the trainee has no disability" do
      let(:trainee) do
        create(:trainee, disability_disclosure: Diversities::DISABILITY_DISCLOSURE_ENUMS[:no_disability])
      end

      it "returns the 'no known impairment' HESA code" do
        expect(hesa_disabilities).to eq("disability1" => "95")
      end
    end

    context "when the trainee has not provided disability information" do
      let(:trainee) { create(:trainee, :disability_not_provided) }

      it "returns the 'prefer not to say' HESA code" do
        expect(hesa_disabilities).to eq("disability1" => "98")
      end

      context "when the stored value was already 'not available'" do
        before { trainee.create_hesa_trainee_detail!(hesa_disabilities: { "disability1" => "99" }) }

        it "preserves the 'not available' HESA code" do
          expect(hesa_disabilities).to eq("disability1" => "99")
        end
      end
    end

    context "when disability disclosure is not set" do
      let(:trainee) { create(:trainee, disability_disclosure: nil) }

      it "returns an empty hash" do
        expect(hesa_disabilities).to eq({})
      end
    end
  end
end
