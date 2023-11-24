# frozen_string_literal: true

require "rails_helper"

describe PlacementDetailForm, type: :model do
  let(:params) { {} }
  let(:trainee) { create(:trainee) }
  let(:form_store) { class_double(FormStore) }

  subject { described_class.new(trainee, params: params, store: form_store) }

  before do
    allow(form_store).to receive(:get).and_return(nil)
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:placement_detail) }
    it { is_expected.to validate_inclusion_of(:placement_detail).in_array(PLACEMENT_DETAIL_ENUMS.values) }
  end

  describe "#stash" do
    let(:params) { { placement_detail: PLACEMENT_DETAIL_ENUMS[:has_placement_detail] } }

    it "uses FormStore to temporarily save the fields under a key combination of trainee ID and placement_detail" do
      expect(form_store).to receive(:set).with(trainee.id, :placement_detail, subject.fields)

      subject.stash
    end
  end

  describe "#save!" do
    let(:params) { { placement_detail: PLACEMENT_DETAIL_ENUMS[:no_placement_detail] } }

    it "clears store and set progress for placements to true" do
      expect(form_store).to receive(:set).with(trainee.id, :placement_detail, nil)

      expect {
        subject.save!
      }.to change(trainee.reload.progress, :placements).from(false).to(true)
    end
  end
end
