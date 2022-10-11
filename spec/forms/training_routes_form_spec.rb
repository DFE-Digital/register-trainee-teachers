# frozen_string_literal: true

require "rails_helper"

describe TrainingRoutesForm do
  let(:params) { { training_route: "provider_led_postgrad" } }
  let(:trainee) { create(:trainee, :incomplete) }
  let(:form_store) { class_double(FormStore) }

  subject { described_class.new(trainee, params: params, store: form_store) }

  before do
    allow(form_store).to receive(:get).and_return(nil)
  end

  describe "validations" do
    before { subject.validate }

    context "without a training_route" do
      let(:params) { {} }
      let(:trainee) { build(:trainee, :incomplete, training_route: nil) }
      let(:error_attr) { "activemodel.errors.models.training_routes_form.attributes.training_route" }

      it "is invalid" do
        expect(subject.errors[:training_route]).to include(I18n.t("#{error_attr}.blank"))
      end
    end
  end

  describe "#stash" do
    it "uses FormStore to temporarily save the fields under a key combination of trainee ID and training_routes" do
      expect(form_store).to receive(:set).with(trainee.id, :training_routes, subject.params)

      subject.stash
    end

    it "does not save to the database" do
      expect(form_store).to receive(:set).with(trainee.id, :training_routes, subject.params)

      expect { subject.stash }.not_to change(trainee, :training_route)
    end
  end

  describe "#save" do
    before do
      allow(form_store).to receive(:get).and_return(params)
      allow(form_store).to receive(:set).with(trainee.id, :training_routes, nil)
    end

    it "takes any data from the form store and saves it to the database and clears the store data" do
      expect(form_store).to receive(:set).with(trainee.id, :training_routes, nil)
      expect { subject.save! }.to change(trainee, :training_route).to("provider_led_postgrad")
    end
  end
end
