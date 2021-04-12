# frozen_string_literal: true

require "rails_helper"

module ApplyApi
  describe ImportApplication do
    describe "#call" do
      let(:application) { JSON.parse(ApiStubs::ApplyApi.application) }

      subject { described_class.call(application: application) }

      context "when the provider does not exist in register" do
        let(:provider) { create(:provider) }

        it "returns nil" do
          expect(subject).to be_nil
        end
      end

      context "when the provider exists in register" do
        let(:provider_code) { application["attributes"]["course"]["training_provider_code"] }
        let(:provider) { create(:provider, code: provider_code) }

        it "creates the apply_application and associates it with that provider" do
          expect { subject }.to change { provider.apply_applications.count }.by(1)
          expect(provider.apply_applications.first.application).to eq application.to_json
        end

        context "and the apply application also exists in register" do
          before do
            create(:apply_application, apply_id: application["id"])
          end

          it "does not create a duplicate" do
            expect { subject }.not_to(change { ApplyApplication.count })
          end
        end
      end
    end
  end
end
