# frozen_string_literal: true

require "rails_helper"

RSpec.describe SystemAdmin::SchoolForm, type: :model do
  subject(:school_form) { described_class.new(school, params:) }

  let!(:school) { create(:school) }

  describe "#clear_stash" do
    let(:form_store) { FormStores::SystemAdmin::SchoolFormStore }
    let(:params) { {} }

    before do
      allow(form_store).to receive(:clear_all).and_call_original
    end

    it "deletes the cached key from the FormStore" do
      expect(subject.clear_stash).to contain_exactly(:system_admin_school)
      expect(form_store).to have_received(:clear_all).with(school.id)
    end
  end

  describe "#stash" do
    let(:form_store) { FormStores::SystemAdmin::SchoolFormStore }

    context "when valid" do
      let(:params) do
        {
          lead_partner: false,
        }
      end

      before do
        allow(form_store).to receive(:set).and_call_original
      end

      it "sets the FormStore with the form attributes" do
        expect(school_form.stash).to eq(true)
        expect(school_form.errors).to be_blank
        expect(form_store).to have_received(:set).with(school.id, :system_admin_school, { "lead_partner" => false })
      end
    end

    context "when not valid" do
      let(:params) do
        {
          lead_partner: nil,
        }
      end

      before do
        allow(form_store).to receive(:set)
      end

      it "sets the FormStore with the form attributes" do
        expect(school_form.stash).to eq(false)
        expect(school_form.errors).to contain_exactly("Lead partner is not included in the list")
      end
    end
  end

  describe "#save" do
    context "when valid" do
      context "when lead_partner = false" do
        let(:params) do
          {
            lead_partner: false,
          }
        end

        it "does not create Lead Partner" do
          expect(school_form.save).to eq(true)
          expect(school_form.errors).to be_blank

          school.reload

          expect(school.lead_partner).to be_nil
        end

        context "when School is a Lead Partner" do
          before do
            create(:lead_partner, :lead_school, school:)
          end

          it "discards the Lead Partner" do
            expect(school_form.save).to eq(true)
            expect(school_form.errors).to be_blank

            school.reload

            expect(school.lead_partner).to be_discarded
          end
        end
      end

      context "when lead_partner = true" do
        let(:params) do
          {
            lead_partner: true,
          }
        end

        context "when School has an undiscarded Lead Partner" do
          let!(:lead_partner) { create(:lead_partner, :lead_school, school:) }

          it "returns true" do
            expect(school_form.save).to eq(true)

            school.reload

            expect(school.lead_partner).to be_present
            expect(school.lead_partner).to be_undiscarded
          end
        end

        context "when School has a discarded Lead Partner" do
          let!(:lead_partner) { create(:lead_partner, :lead_school, school:, discarded_at: Time.now) }

          it "undiscards the Lead Partner" do
            expect(school_form.save).to eq(true)

            school.reload

            expect(school.lead_partner).to be_present
            expect(school.reload.lead_partner).to be_undiscarded
          end
        end

        context "when School is not a Lead Partner" do
          it "creates a Lead Partner record associated with the School" do
            expect(school_form.save).to eq(true)

            school.reload

            expect(school.lead_partner).to be_present
            expect(school.lead_partner).to be_undiscarded
          end
        end
      end
    end

    context "when invalid" do
      context "when lead_partner = true" do
        let(:params) do
          {
            lead_partner: nil,
          }
        end

        it "does not create a Lead Partner" do
          expect(school_form.save).to eq(false)
          expect(school_form.errors).to be_present

          school.reload

          expect(school.lead_partner).to be_nil
        end
      end
    end
  end
end
