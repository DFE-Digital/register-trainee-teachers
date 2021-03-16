# frozen_string_literal: true

require "rails_helper"

module Diversities
  describe DisabilityDetailForm, type: :model do
    let(:trainee) { build(:trainee, :disabled) }

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
  end
end
