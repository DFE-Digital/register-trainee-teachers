# frozen_string_literal: true

require "rails_helper"

module ApplyApi
  describe ImportApplication do
    describe "#call" do
      let(:application_data) { JSON.parse(ApiStubs::ApplyApi.application) }

      subject { described_class.call(application_data: application_data) }

      context "when the provider exists in register" do
        let(:provider_code) { application_data["attributes"]["course"]["training_provider_code"] }
        let!(:provider) { create(:provider, code: provider_code) }

        it "returns the application record" do
          expect(subject).to be_instance_of(ApplyApplication)
        end

        it "creates the apply_application with state 'importable' and associates it with that provider" do
          expect { subject }.to change { provider.apply_applications.importable.count }.by(1)
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

        context "when the provider type is an HEI" do
          before do
            application_data["attributes"]["course"]["training_provider_type"] = "university"
          end

          it "creates an apply_application with the state 'non_importable_hei'" do
            expect { subject }.to change { provider.apply_applications.non_importable_hei.count }.by(1)
          end
        end
      end

      context "when there is missing data" do
        let(:application_data) { { "attributes" => { "course" => nil } } }

        it "will not create apply application" do
          expect { subject }.to raise_error ApplyApi::ImportApplication::ApplyApiMissingDataError
        end
      end

      context "the course accredited_provider_code is present" do
        let(:provider_a) { create(:provider) }
        let(:provider_b) { create(:provider) }

        let(:application_data) do
          JSON.parse(ApiStubs::ApplyApi.application(course_attributes: {
            accredited_provider_code: provider_a.code,
            training_provider_code: provider_b.code,
          }))
        end

        it "creates the apply_application and associates it with the provider matching accredited_body_code" do
          expect { subject }.to change { provider_a.apply_applications.importable.count }.by(1)
        end
      end
    end
  end
end
