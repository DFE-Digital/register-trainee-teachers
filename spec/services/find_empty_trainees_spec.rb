# frozen_string_literal: true

require "rails_helper"

describe FindEmptyTrainees do
  let(:provider) { create(:provider) }

  let!(:draft_trainee_with_no_data) do
    Trainee.create(provider: provider, training_route: TRAINING_ROUTE_ENUMS[:assessment_only])
  end

  subject { described_class.call }

  before do
    create(:trainee, :draft, provider: provider)
  end

  it "returns only trainees that have no data" do
    expect(subject).to match_array(draft_trainee_with_no_data)
  end

  context "returning trainee ID's only" do
    subject { described_class.call(ids_only: true) }

    it { is_expected.to match_array([draft_trainee_with_no_data.id]) }
  end

  context "if excluded fields have changed" do
    before do
      stub_const("FindEmptyTrainees::EXCLUDED_FIELDS", ["random_field"])
    end

    it "raises an error" do
      expect { described_class.call }.to raise_error(FindEmptyTrainees::FieldsDoNotExistError)
    end
  end

  context "for early year routes" do
    let!(:draft_trainee_with_no_data) do
      create(:trainee, :incomplete, :early_years_salaried)
    end

    subject { described_class.call }

    it { is_expected.to match_array(draft_trainee_with_no_data) }
  end
end
