# frozen_string_literal: true

require "rails_helper"

describe PerformanceProfileSignOffForm, type: :model do
  let(:sign_off) { "confirmed" }
  let(:error_message) { form.errors.full_messages.first }
  let(:provider) { create(:provider) }
  let(:user_context) { UserWithOrganisationContext.new(user: user, session: {}) }
  let(:user) { create(:user, providers: [provider]) }

  subject(:form) { described_class.new(sign_off: sign_off, provider: provider, user: user_context) }

  describe "#valid?" do
    context "with a blank sign off" do
      let(:sign_off) { nil }

      it "returns the correct error message" do
        expect(form.valid?).to be false
        expect(error_message).to include "Please confirm sign off"
      end
    end

    context "with a invalid sign off" do
      let(:sign_off) { "invalid" }

      it "returns the correct error message" do
        expect(form.valid?).to be false
        expect(error_message).to include "Please confirm sign off"
      end
    end

    context "with a valid sign_off" do
      it "returns valid" do
        expect(form.valid?).to be true
      end
    end
  end

  describe "#save!" do
    context "with a blank sign off" do
      let(:sign_off) { nil }

      it "returns the correct error message" do
        expect(form.save!).to be false
      end
    end

    context "with a invalid sign off" do
      let(:sign_off) { "invalid" }

      it "returns the correct error message" do
        expect(form.save!).to be false
      end
    end

    context "with a valid sign_off" do
      before do
        create(:academic_cycle, :previous)
      end

      context "provider performance profile awaiting sign off" do
        it "saves a new performance profile sign off" do
          expect { form.save! }.to change { provider.performance_profile_awaiting_sign_off? }.from(true).to(false)
          .and change { provider.sign_offs.count }.from(0).to(1)
        end

        it "returns true" do
          expect(form.save!).to be true
        end
      end

      context "provider performance profile signed off" do
        let(:previous_performance_profile_sign_off) { build(:sign_off, academic_cycle: AcademicCycle.previous) }
        let(:provider) { create(:provider, sign_offs: [previous_performance_profile_sign_off]) }

        it "updates the previous performance profile sign off" do
          expect {
            form.save!
          }.to change { previous_performance_profile_sign_off.reload.user }.to(user)
        end

        it "does not create a new performance profile sign off" do
          expect {
            form.save!
          }.to not_change { provider.sign_offs.count }.from(1)
        end

        it "returns true" do
          expect(form.save!).to be true
        end
      end
    end
  end
end
