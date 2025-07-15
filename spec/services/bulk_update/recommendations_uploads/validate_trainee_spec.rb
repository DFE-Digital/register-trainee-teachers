# frozen_string_literal: true

require "rails_helper"

module BulkUpdate
  module RecommendationsUploads
    describe ValidateTrainee do
      let(:trainee_lookup) { TraineeLookup.new([row], trainee.provider) }

      subject(:service) do
        described_class.new(row: row, provider: trainee.provider, trainee_lookup: trainee_lookup)
      end

      context "with a single trainee" do
        let(:trainee) { create(:trainee, :bulk_recommend) }

        context "and an empty row" do
          let(:row) do
            Row.new({
              "trn" => "",
            })
          end

          describe "#valid?" do
            it { expect(service.valid?).to be true }
          end

          describe "#messages" do
            it { expect(service.messages).to eql [] }
          end
        end

        context "and a row with only TRN" do
          let(:row) do
            Row.new({
              "trn" => trainee.trn,
            })
          end

          describe "#valid?" do
            it { expect(service.valid?).to be true }
          end

          describe "#messages" do
            it { expect(service.messages).to eql [] }
          end

          describe "#trainee" do
            it { expect(service.trainee).to eql trainee }
          end

          context "In the wrong state - withdrawn" do
            let(:trainee) { create(:trainee, :bulk_recommend, state: :withdrawn) }

            describe "#valid?" do
              it { expect(service.valid?).to be false }
            end

            describe "#messages" do
              it { expect(service.messages).to eql ["The trainee has withdrawn status - you can only recommend trainees with TRN received status"] }
            end

            describe "#trainee" do
              it { expect(service.trainee).to be_nil }
            end
          end

          context "In the wrong state - recommended for award" do
            let(:trainee) { create(:trainee, :bulk_recommend, state: :recommended_for_award) }

            describe "#valid?" do
              it { expect(service.valid?).to be false }
            end

            describe "#messages" do
              it { expect(service.messages).to eql ["The trainee has Selected for QTS status - you can only recommend trainees with TRN received status"] }
            end

            describe "#trainee" do
              it { expect(service.trainee).to be_nil }
            end
          end

          context "In the wrong state - submitted for TRN" do
            let(:trainee) { create(:trainee, :bulk_recommend, state: :submitted_for_trn) }

            describe "#valid?" do
              it { expect(service.valid?).to be false }
            end

            describe "#messages" do
              it { expect(service.messages).to eql ["The trainee has pending TRN status - you can only recommend trainees with TRN received status"] }
            end

            describe "#trainee" do
              it { expect(service.trainee).to be_nil }
            end
          end
        end

        context "and a row with only HESA ID" do
          let(:trainee) { create(:trainee, :bulk_recommend_from_hesa) }

          let(:row) do
            Row.new({
              "hesa id" => trainee.hesa_id,
            })
          end

          describe "#valid?" do
            it { expect(service.valid?).to be true }
          end

          describe "#messages" do
            it { expect(service.messages).to eql [] }
          end

          describe "#trainee" do
            it { expect(service.trainee).to eql trainee }
          end
        end

        context "and a row with only Provider Trainee ID" do
          let(:row) do
            Row.new({
              "provider trainee id" => trainee.provider_trainee_id,
            })
          end

          describe "#valid?" do
            it { expect(service.valid?).to be true }
          end

          describe "#messages" do
            it { expect(service.messages).to eql [] }
          end

          describe "#trainee" do
            it { expect(service.trainee).to eql trainee }
          end
        end

        context "and a row without Degrees" do
          let(:trainee) { create(:trainee, :bulk_recommend, :without_degrees) }

          let(:row) do
            Row.new({
              "provider trainee id" => trainee.provider_trainee_id,
            })
          end

          describe "#valid?" do
            it { expect(service.valid?).to be false }
          end

          describe "#messages" do
            it { expect(service.messages).to eql(["Add at least one degree"]) }
          end

          describe "#trainee" do
            it { expect(service.trainee).to eql trainee }
          end
        end

        context "and a row without Placements" do
          let(:trainee) { create(:trainee, :bulk_recommend, :provider_led_postgrad, :without_placements) }

          let(:row) do
            Row.new({
              "provider trainee id" => trainee.provider_trainee_id,
            })
          end

          describe "#valid?" do
            it { expect(service.valid?).to be true }
          end

          describe "#messages" do
            it { expect(service.messages).to be_empty }
          end

          describe "#trainee" do
            it { expect(service.trainee).to eql trainee }
          end
        end
      end

      context "with multiple trainee matches with not trn received" do
        let(:trainee) { create(:trainee, :bulk_recommend, state: :deferred) }

        context "and a row with only TRN" do
          let!(:trainee_two) { create(:trainee, provider: trainee.provider, trn: trainee.trn, state: :deferred) }

          let(:row) do
            Row.new({
              "trn" => trainee.trn,
            })
          end

          describe "#valid?" do
            it { expect(service.valid?).to be false }
          end

          describe "#messages" do
            it { expect(service.messages).to eql ["2 trainee records have the same TRN but none have TRN received status - you can only recommend trainees with TRN received status"] }
          end

          describe "#trainee" do
            it { expect(service.trainee).to be_nil }
          end
        end
      end

      context "with multiple trainee matches" do
        let(:trainee) { create(:trainee, :bulk_recommend) }

        context "and a row with only TRN" do
          let!(:trainee_two) { create(:trainee, provider: trainee.provider, trn: trainee.trn, state: :trn_received) }

          let(:row) do
            Row.new({
              "trn" => trainee.trn,
            })
          end

          describe "#valid?" do
            it { expect(service.valid?).to be false }
          end

          describe "#messages" do
            it { expect(service.messages).to eql ["2 trainee records with TRN received status have the same TRN - contact becomingateacher@digital.education.gov.uk to fix this"] }
          end

          describe "#trainee" do
            it { expect(service.trainee).to be_nil }
          end
        end

        context "and a row with only HESA ID" do
          let(:trainee) { create(:trainee, :bulk_recommend_from_hesa) }
          let(:row) do
            Row.new({
              "hesa id" => trainee.hesa_id,
            })
          end
          let!(:trainee_two) { create(:trainee, provider: trainee.provider, state: :trn_received) }

          before { trainee_two.update_column(:hesa_id, trainee.hesa_id) }

          describe "#valid?" do
            it { expect(service.valid?).to be false }
          end

          describe "#messages" do
            it { expect(service.messages).to eql ["2 trainee records with TRN received status have the same HESA ID - contact becomingateacher@digital.education.gov.uk to fix this"] }
          end

          describe "#trainee" do
            it { expect(service.trainee).to be_nil }
          end
        end

        context "and a row with only Provider Trainee ID" do
          let!(:trainee_two) { create(:trainee, provider: trainee.provider, provider_trainee_id: trainee.provider_trainee_id, state: :trn_received) }

          let(:row) do
            Row.new({
              "provider trainee id" => trainee.provider_trainee_id,
            })
          end

          describe "#valid?" do
            it { expect(service.valid?).to be false }
          end

          describe "#messages" do
            it { expect(service.messages).to eql ["2 trainee records with TRN received status have the same provider trainee ID - contact becomingateacher@digital.education.gov.uk to fix this"] }
          end

          describe "#trainee" do
            it { expect(service.trainee).to be_nil }
          end
        end
      end

      context "with no trainee matches" do
        let(:trainee) { create(:trainee, :bulk_recommend) }

        context "and a row with only TRN" do
          let(:row) do
            Row.new({
              "trn" => "NotMatch",
            })
          end

          describe "#messages" do
            it { expect(service.messages).to eql ["TRN must match a trainee record"] }
          end
        end

        context "and a row with only HESA ID" do
          let(:row) do
            Row.new({
              "hesa id" => "NotMatch",
            })
          end

          describe "#messages" do
            it { expect(service.messages).to eql ["HESA ID must match a trainee record"] }
          end
        end

        context "and a row with only Provider Trainee ID" do
          let(:row) do
            Row.new({
              "provider trainee id" => "NotMatch",
            })
          end

          describe "#messages" do
            it { expect(service.messages).to eql ["Provider trainee ID must match a trainee record"] }
          end
        end

        context "and a row with HESA ID and Provider Trainee ID" do
          let(:row) do
            Row.new({
              "hesa id" => "NotMatch",
              "provider trainee id" => "NotMatch",
            })
          end

          describe "#messages" do
            it { expect(service.messages).to eql ["HESA ID or provider trainee ID must match a trainee record"] }
          end
        end

        context "and a row with HESA ID, Provider Trainee ID and TRN" do
          let(:row) do
            Row.new({
              "hesa id" => "NotMatch",
              "provider trainee id" => "NotMatch",
              "trn" => "NotMatch",
            })
          end

          describe "#messages" do
            it { expect(service.messages).to eql ["TRN, HESA ID or provider trainee ID must match a trainee record"] }
          end
        end
      end
    end
  end
end
