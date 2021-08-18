# frozen_string_literal: true

require "rails_helper"

module ApplyApi
  describe ImportApplication do
    describe "#call" do
      let(:application_data) { JSON.parse(ApiStubs::ApplyApi.application) }

      subject { described_class.call(application_data: application_data) }

      context "when the provider does not exist in register" do
        let(:provider) { create(:provider) }

        it "returns nil" do
          expect(subject).to be_nil
        end
      end

      context "when the provider exists in register" do
        let(:provider_code) { application_data["attributes"]["course"]["training_provider_code"] }
        let!(:provider) { create(:provider, code: provider_code) }

        it "returns the application record" do
          expect(subject).to be_instance_of(ApplyApplication)
        end

        it "creates the apply_application and associates it with that provider" do
          expect { subject }.to change { provider.apply_applications.count }.by(1)
          expect(provider.apply_applications.first.application).to eq(application_data.to_json)
        end

        context "and the apply application_data also exists in register" do
          before do
            create(:apply_application, apply_id: application_data["id"])
          end

          it "does not create a duplicate" do
            expect { subject }.not_to(change { ApplyApplication.count })
          end
        end
      end

      context "when the provider type is an HEI" do
        before do
          application_data["attributes"]["course"]["training_provider_type"] = "university"
        end

        it "will not create apply application " do
          expect { subject }.not_to(change { ApplyApplication.count })
        end
      end

      context "when there is missing data" do
        let(:application_data) { { "attributes" => { "course" => nil } } }

        it "will not create apply application " do
          expect { subject }.to raise_error ApplyApi::ImportApplication::ApplyApiMissingDataError
        end
      end
    end
  end
end
