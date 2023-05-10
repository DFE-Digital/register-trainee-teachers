# frozen_string_literal: true

require "rails_helper"

module BulkUpdate
  module RecommendationsUploads
    describe ValidateTrainee do
      subject(:service) { described_class.new(row: row, provider: trainee.provider) }

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

          context "In the wrong state" do
            let(:trainee) { create(:trainee, :bulk_recommend, state: :withdrawn) }

            describe "#valid?" do
              it { expect(service.valid?).to be false }
            end

            describe "#messages" do
              it { expect(service.messages).to eql ["Trainee is Withdrawn"] }
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
              "provider trainee id" => trainee.trainee_id,
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
            it { expect(service.messages).to eql ["Multiple trainees in state 'trn received' found via TRN"] }
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
            it { expect(service.messages).to eql ["Multiple trainees in state 'trn received' found via HESA ID"] }
          end

          describe "#trainee" do
            it { expect(service.trainee).to be_nil }
          end
        end

        context "and a row with only Provider Trainee ID" do
          let!(:trainee_two) { create(:trainee, provider: trainee.provider, trainee_id: trainee.trainee_id, state: :trn_received) }

          let(:row) do
            Row.new({
              "provider trainee id" => trainee.trainee_id,
            })
          end

          describe "#valid?" do
            it { expect(service.valid?).to be false }
          end

          describe "#messages" do
            it { expect(service.messages).to eql ["Multiple trainees in state 'trn received' found via the provider trainee ID"] }
          end

          describe "#trainee" do
            it { expect(service.trainee).to be_nil }
          end
        end
      end
    end
  end
end
