# frozen_string_literal: true

require "rails_helper"

describe "trainees:create_from_apply" do
  let(:args) {
    Rake::TaskArguments.new(%i[recruitment_cycle_year], [recruitment_cycle_year])
  }

  let(:apply_application_sync_request) { create(:apply_application_sync_request, :successful, recruitment_cycle_year:) }

  let(:recruitment_cycle_year) { 2023 }
  let(:application_data) { JSON.parse(ApiStubs::RecruitsApi.application) }
  let(:application) { build(:apply_application, :importable) }

  it "called retrieved applications" do
    apply_application_sync_request

    allow(RecruitsApi::RetrieveApplications).to receive(:call).with({ changed_since: apply_application_sync_request.created_at, recruitment_cycle_year: recruitment_cycle_year }).and_return([application_data])
    allow(RecruitsApi::ImportApplication).to receive(:call).with({ application_data: }).and_return(application)
    expect(Trainees::CreateFromApply).to receive(:call).with({ application: })

    Rake::Task["trainees:create_from_apply"].execute(args)

    subject
  end
end
