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
          training_partner: false,
        }
      end

      before do
        allow(form_store).to receive(:set).and_call_original
      end

      it "sets the FormStore with the form attributes" do
        expect(school_form.stash).to be(true)
        expect(school_form.errors).to be_blank
        expect(form_store).to have_received(:set).with(school.id, :system_admin_school, { "training_partner" => false })
      end
    end

    context "when not valid" do
      let(:params) do
        {
          training_partner: nil,
        }
      end

      before do
        allow(form_store).to receive(:set)
      end

      it "does not set the FormStore with the form attributes" do
        expect(school_form.stash).to be(false)
        expect(school_form.errors).to contain_exactly("Training partner is not included in the list")
      end
    end
  end

  describe "#save" do
    context "when valid" do
      context "when training_partner = false" do
        let(:params) do
          {
            training_partner: false,
          }
        end

        context "when School is not a Training Partner" do
          it "does not create Training Partner" do
            expect(school_form.save).to be(true)
            expect(school_form.errors).to be_blank

            school.reload

            expect(school.training_partner).to be_nil
          end
        end

        context "when School is a discarded Training Partner" do
          before do
            create(:training_partner, :school, school:).discard!
          end

          it "returns true" do
            expect(school_form.save).to be(true)
            expect(school_form.errors).to be_blank

            school.reload

            expect(school.training_partner).to be_discarded
          end
        end

        context "when School is an undiscarded Training Partner" do
          before do
            create(:training_partner, :school, school:)
          end

          it "discards the Training Partner" do
            expect(school_form.save).to be(true)
            expect(school_form.errors).to be_blank

            school.reload

            expect(school.training_partner).to be_discarded
          end
        end
      end

      context "when training_partner = true" do
        let(:params) do
          {
            training_partner: true,
          }
        end

        context "when School has an undiscarded Training Partner" do
          let!(:training_partner) { create(:training_partner, :school, school:) }

          it "returns true" do
            expect(school_form.save).to be(true)

            school.reload

            expect(school.training_partner).to be_present
            expect(school.training_partner).to be_undiscarded
          end
        end

        context "when School has a discarded Training Partner" do
          let!(:training_partner) { create(:training_partner, :school, school: school, discarded_at: Time.zone.now) }

          it "undiscards the Training Partner" do
            expect(school_form.save).to be(true)

            school.reload

            expect(school.training_partner).to be_present
            expect(school.training_partner).to be_undiscarded
          end
        end

        context "when School is not a Training Partner" do
          it "creates a Training Partner" do
            expect(school_form.save).to be(true)

            school.reload

            expect(school.training_partner).to be_present
            expect(school.training_partner).to be_undiscarded
          end
        end
      end
    end

    context "when invalid" do
      let(:params) do
        {
          training_partner: nil,
        }
      end

      it "does not create a Training Partner" do
        expect(school_form.save).to be(false)
        expect(school_form.errors).to be_present

        school.reload

        expect(school.training_partner).to be_nil
      end
    end
  end
end
