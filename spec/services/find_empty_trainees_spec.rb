# frozen_string_literal: true

require "rails_helper"

describe FindEmptyTrainees do
  let(:provider) { create(:provider) }

  let!(:draft_trainee_with_no_data) do
    Trainee.create(provider: provider, training_route: ReferenceData::TRAINING_ROUTES.assessment_only.name)
  end

  subject { described_class.call }

  before do
    create(:trainee, :draft, provider:)
  end

  it "returns only trainees that have no data" do
    expect(subject).to match_array(draft_trainee_with_no_data)
  end

  context "returning trainee ID's only" do
    subject { described_class.call(ids_only: true) }

    it { is_expected.to contain_exactly(draft_trainee_with_no_data.id) }
  end

  context "if trainee fields have changed" do
    before do
      allow(Trainee).to receive(:column_names).and_return(["random_field"])
    end

    it "raises an error" do
      expect { described_class.call }.to raise_error(FindEmptyTrainees::FieldsDoNotExistError)
    end
  end

  context "for early year routes" do
    let!(:draft_trainee_with_no_data) do
      create(:trainee, :incomplete, :early_years_salaried, study_mode: nil, itt_start_date: nil, itt_end_date: nil)
    end

    subject { described_class.call }

    it { is_expected.to match_array(draft_trainee_with_no_data) }
  end

  context "for trainees with a provider_trainee_id" do
    # trainees with a provider_trainee_id should not be classed as empty
    let!(:draft_trainee_with_no_data) do
      Trainee.create(provider: provider, training_route: ReferenceData::TRAINING_ROUTES.assessment_only.name, provider_trainee_id: 1)
    end

    subject { described_class.call }

    it { is_expected.to be_empty }
  end
end
