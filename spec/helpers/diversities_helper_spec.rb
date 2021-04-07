# frozen_string_literal: true

require "rails_helper"

describe DiversitiesHelper do
  include DiversitiesHelper

  let(:trainee) { build(:trainee) }

  subject { helper.diversity_confirm_path(trainee) }

  before do
    allow(DiversityForm).to receive(:new).and_return(diversity_form)
  end

  describe "#diversity_confirm_path" do
    context "diversity is not disclosed" do
      let(:diversity_form) { double(diversity_disclosed?: false) }

      it "returns the path to diversity confirm page" do
        expect(subject).to eq(trainee_diversity_confirm_path(trainee))
      end
    end

    context "diversity is disclosed" do
      context "ethnic group not specified" do
        let(:diversity_form) { double(diversity_disclosed?: true, ethnic_group: nil) }

        it "returns the path to the ethnic group page" do
          expect(subject).to eq(edit_trainee_diversity_ethnic_group_path(trainee))
        end
      end

      context "ethnic group specified but ethnic background is not" do
        let(:diversity_form) do
          double(diversity_disclosed?: true, ethnic_group: :mixed, ethnic_group_provided?: true, ethnic_background: nil)
        end

        it "returns the path to the ethnic background page" do
          expect(subject).to eq(edit_trainee_diversity_ethnic_background_path(trainee))
        end
      end

      context "ethnic group and background are specified" do
        let(:diversity_form) do
          double(diversity_disclosed?: true,
                 ethnic_group: :mixed,
                 ethnic_group_provided?: true,
                 ethnic_background: :not_provided,
                 disability_disclosure: nil)
        end

        it "returns the path to the disability disclosure page" do
          expect(subject).to eq(edit_trainee_diversity_disability_disclosure_path(trainee))
        end
      end

      context "ethnic group and background are specified" do
        let(:diversity_form) do
          double(diversity_disclosed?: true,
                 ethnic_group: :mixed,
                 ethnic_group_provided?: true,
                 ethnic_background: :not_provided,
                 disability_disclosure: :disabled,
                 disabled?: true,
                 disabilities: [])
        end

        it "returns the path to the disability details page" do
          expect(subject).to eq(edit_trainee_diversity_disability_detail_path(trainee))
        end
      end

      context "ethnic group, background and no disability are specified" do
        let(:diversity_form) do
          double(diversity_disclosed?: true,
                 ethnic_group: :mixed,
                 ethnic_group_provided?: true,
                 ethnic_background: :not_provided,
                 disability_disclosure: :no_disability,
                 disabled?: false,
                 disabilities: [])
        end

        it "returns the path to the confirm page" do
          expect(subject).to eq(trainee_diversity_confirm_path(trainee))
        end
      end

      context "all diversity information has been entered" do
        let(:diversity_form) do
          double(diversity_disclosed?: true,
                 ethnic_group: :mixed,
                 ethnic_group_provided?: true,
                 ethnic_background: :not_provided,
                 disability_disclosure: :disabled,
                 disabilities: [Disability.new])
        end

        it "returns the path to the diversity confirm page" do
          expect(subject).to eq(trainee_diversity_confirm_path(trainee))
        end
      end
    end
  end
end
