# frozen_string_literal: true

require "rails_helper"

module Funding
  describe TrainingInitiativesForm, type: :model do
    let(:params) { {} }
    let(:trainee) { create(:trainee, training_initiative: ROUTE_INITIATIVES_ENUMS[:no_initiative]) }
    let(:form_store) { class_double(FormStore) }

    subject { described_class.new(trainee, params: params, store: form_store) }

    before do
      allow(form_store).to receive(:get).and_return(nil)
    end

    describe "validations" do
      it { is_expected.to validate_presence_of(:training_initiative) }
      it { is_expected.to validate_inclusion_of(:training_initiative).in_array(ROUTE_INITIATIVES_ENUMS.values) }
    end

    describe "#stash" do
      it "uses FormStore to temporarily save the fields under a key combination of trainee ID and training_initiative" do
        expect(form_store).to receive(:set).with(trainee.id, :training_initiative, subject.fields)

        subject.stash
      end
    end

    describe "#save!" do
      let(:transition_to_teach) { ROUTE_INITIATIVES_ENUMS[:transition_to_teach] }

      before do
        allow(form_store).to receive(:get).and_return({ "training_initiative" => transition_to_teach })
        allow(form_store).to receive(:set).with(trainee.id, :training_initiative, nil)
      end

      it "takes any data from the form store and saves it to the database" do
        expect { subject.save! }.to change(trainee, :training_initiative).to(transition_to_teach)
      end
    end
  end
end
