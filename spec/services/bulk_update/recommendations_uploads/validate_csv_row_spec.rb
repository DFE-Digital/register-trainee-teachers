# frozen_string_literal: true

require "rails_helper"

module BulkUpdate
  module RecommendationsUploads
    describe ValidateCsvRow do
      subject(:service) { described_class.new(row:, trainee:) }

      context "without a matched trainee" do
        let(:trainee) { nil }

        context "When row is valid" do
          let(:row) do
            Row.new({
              "trn" => "1234567",
              "hesa id" => "12345678912345678",
              "provider trainee id" => "1234567",
              "last names" => "Blobby",
              "first names" => "Russell",
              "lead school" => "Bluemeadow High",
              "qts or eyts" => "QTS",
              "route" => "Early years (salaried)",
              "phase" => "Early years",
              "age range" => "0 to 5",
              "subject" => "Early years teaching",
              "date qts or eyts standards met" => Date.yesterday.strftime("%d/%m/%Y"),
            })
          end

          describe "#valid?" do
            it { expect(service.valid?).to be true }
          end

          describe "messages" do
            it { expect(service.messages).to eql [] }
          end
        end

        context "When row is invalid" do
          let(:row) do
            Row.new({
              "trn" => "123567", # invalid
              "hesa id" => "1234568912345678", # invalid
              "provider trainee id" => "1234",
              "last names" => "", # cannot be blank
              "first names" => "Russell",
              "lead school" => "Bluemeadow High",
              "qts or eyts" => "QTS",
              "route" => "Early years (salaried)",
              "phase" => "Early years",
              "age range" => "0 to 5",
              "subject" => "Early years teaching",
              "date qts or eyts standards met" => "not-a-date", # invalid
            })
          end

          describe "#valid?" do
            it { expect(service.valid?).to be false }
          end

          describe "messages" do
            it do
              expect(service.messages).to eql(
                [
                  "\"Last Names\" cannot be blank",
                  "TRN must be 7 characters long and contain only numbers",
                  "HESA ID must be 17 characters long and contain only numbers",
                  "Date could not be parsed, please use the format dd/mm/yyyy e.g. 27/02/2022",
                ],
              )
            end
          end
        end
      end

      context "with a matched trainee" do
        let(:trainee) { create(:trainee, :bulk_recommend) }
        let(:trainee_presenter) { ::Reports::TraineeReport.new(trainee) }

        context "When row is valid" do
          let(:row) do
            Row.new({
              "trn" => trainee_presenter.trn,
              "hesa id" => trainee_presenter.hesa_id,
              "provider trainee id" => trainee_presenter.provider_trainee_id,
              "last names" => trainee_presenter.last_names,
              "first names" => trainee_presenter.first_names,
              "lead school" => trainee_presenter.lead_school_name,
              "qts or eyts" => trainee_presenter.qts_or_eyts,
              "route" => trainee_presenter.course_training_route,
              "phase" => trainee_presenter.course_education_phase,
              "age range" => trainee_presenter.course_age_range,
              "subject" => trainee_presenter.subjects,
              "date qts or eyts standards met" => Date.yesterday.strftime("%d/%m/%Y"),
            })
          end

          describe "#valid?" do
            it { expect(service.valid?).to be true }
          end

          describe "messages" do
            it { expect(service.messages).to eql [] }
          end
        end

        context "When row is invalid" do
          let(:row) do
            Row.new({
              "trn" => "123d567", # invalid
              "hesa id" => "123456d8912345678", # invalid
              "provider trainee id" => trainee_presenter.provider_trainee_id,
              "last names" => "", # cannot be blank
              "first names" => trainee_presenter.first_names,
              "lead school" => trainee_presenter.lead_school_name,
              "qts or eyts" => trainee_presenter.qts_or_eyts,
              "route" => trainee_presenter.course_training_route,
              "phase" => trainee_presenter.course_education_phase,
              "age range" => trainee_presenter.course_age_range,
              "subject" => trainee_presenter.subjects,
              "date qts or eyts standards met" => "not-a-date", # invalid
            })
          end

          describe "#valid?" do
            it { expect(service.valid?).to be false }
          end

          describe "messages" do
            it do
              expect(service.messages).to eql(
                [
                  "\"Last Names\" cannot be blank",
                  "TRN must be 7 characters long and contain only numbers",
                  "HESA ID must be 17 characters long and contain only numbers",
                  "Date could not be parsed, please use the format dd/mm/yyyy e.g. 27/02/2022",
                ],
              )
            end
          end
        end
      end
    end
  end
end
