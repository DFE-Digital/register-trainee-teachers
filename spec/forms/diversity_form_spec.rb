# frozen_string_literal: true

require "rails_helper"

shared_examples "a delegate method" do |method_name, form_class|
  describe "##{method_name}" do
    let(:form) { form_class.new(trainee) }

    before do
      allow(form_class).to receive(:new).and_return(form)
    end

    it "delegates to #{form_class}##{method_name}" do
      expect(form).to receive(method_name).at_least(:once)
      subject.send(method_name)
    end
  end
end

describe DiversityForm, type: :model do
  let(:trainee) { build(:trainee) }

  subject { described_class.new(trainee) }

  delegate_methods = {
    Diversities::DisclosureForm => %i[diversity_not_disclosed? diversity_disclosure diversity_disclosed?],
    Diversities::DisabilityDisclosureForm => %i[disabled? no_disability?],
    Diversities::DisabilityDetailForm => %i[disabilities additional_disability],
    Diversities::EthnicGroupForm => %i[ethnic_group not_provided_ethnic_group?],
    Diversities::EthnicBackgroundForm => %i[ethnic_background additional_ethnic_background],
  }

  delegate_methods.each do |form_class, method_names|
    method_names.each do |method_name|
      include_examples "a delegate method", method_name, form_class
    end
  end

  describe "#save!" do
    it "calls the save! method on all diversity forms" do
      expect_any_instance_of(Diversities::DisabilityDetailForm).to receive(:save!)
      expect_any_instance_of(Diversities::DisabilityDisclosureForm).to receive(:save!)
      expect_any_instance_of(Diversities::DisclosureForm).to receive(:save!)
      expect_any_instance_of(Diversities::EthnicBackgroundForm).to receive(:save!)
      expect_any_instance_of(Diversities::EthnicGroupForm).to receive(:save!)

      subject.save!
    end
  end

  describe "#valid?" do
    let(:disability_detail_form) { Diversities::DisabilityDetailForm.new(trainee) }
    let(:disability_disclosure_form) { Diversities::DisabilityDisclosureForm.new(trainee) }
    let(:disclosure_form) { Diversities::DisclosureForm.new(trainee) }
    let(:ethnic_background_form) { Diversities::EthnicBackgroundForm.new(trainee) }
    let(:ethnic_group_form) { Diversities::EthnicGroupForm.new(trainee) }

    before do
      allow(Diversities::DisabilityDetailForm).to receive(:new).and_return(disability_detail_form)
      allow(Diversities::DisabilityDisclosureForm).to receive(:new).and_return(disability_disclosure_form)
      allow(Diversities::DisclosureForm).to receive(:new).and_return(disclosure_form)
      allow(Diversities::EthnicBackgroundForm).to receive(:new).and_return(ethnic_background_form)
      allow(Diversities::EthnicGroupForm).to receive(:new).and_return(ethnic_group_form)
    end

    it "calls the valid? method on all diversity forms" do
      expect(disability_detail_form).to receive(:valid?).at_least(1).time.and_return(true)
      expect(disability_disclosure_form).to receive(:valid?).at_least(1).time.and_return(true)
      expect(disclosure_form).to receive(:valid?).at_least(1).time.and_return(true)
      expect(ethnic_background_form).to receive(:valid?).at_least(1).time.and_return(true)
      expect(ethnic_group_form).to receive(:valid?).at_least(1).time.and_return(true)

      expect(subject.valid?).to be_truthy
    end
  end

  describe "#errors" do
    let(:disability_detail_form) { Diversities::DisabilityDetailForm.new(trainee) }
    let(:disability_disclosure_form) { Diversities::DisabilityDisclosureForm.new(trainee) }
    let(:disclosure_form) { Diversities::DisclosureForm.new(trainee) }
    let(:ethnic_background_form) { Diversities::EthnicBackgroundForm.new(trainee) }
    let(:ethnic_group_form) { Diversities::EthnicGroupForm.new(trainee) }

    before do
      allow(Diversities::DisabilityDetailForm).to receive(:new).and_return(disability_detail_form)
      allow(Diversities::DisabilityDisclosureForm).to receive(:new).and_return(disability_disclosure_form)
      allow(Diversities::DisclosureForm).to receive(:new).and_return(disclosure_form)
      allow(Diversities::EthnicBackgroundForm).to receive(:new).and_return(ethnic_background_form)
      allow(Diversities::EthnicGroupForm).to receive(:new).and_return(ethnic_group_form)
    end

    it "calls the errors method on all diversity forms" do
      expect(disability_detail_form).to receive(:errors).at_least(1).time.and_return([])
      expect(disability_disclosure_form).to receive(:errors).at_least(1).time.and_return([])
      expect(disclosure_form).to receive(:errors).at_least(1).time.and_return([])
      expect(ethnic_background_form).to receive(:errors).at_least(1).time.and_return([])
      expect(ethnic_group_form).to receive(:errors).at_least(1).time.and_return([])

      expect(subject.errors).to be_a(Array)
    end
  end

  describe "#ethnic_group_provided?" do
    let(:form) { Diversities::EthnicGroupForm.new(trainee) }

    before do
      allow(Diversities::EthnicGroupForm).to receive(:new).and_return(form)
    end

    it "delegates to #{Diversities::EthnicGroupForm}#not_provided_ethnic_group?" do
      expect(form).to receive(:not_provided_ethnic_group?).at_least(:once)
      subject.ethnic_group_provided?
    end
  end

  describe "#missing_fields" do
    subject { described_class.new(trainee).missing_fields }

    it { is_expected.to eq([[]]) }

    context "with invalid?d diversity forms" do
      let(:trainee) { build(:trainee, diversity_disclosure: nil) }

      it { is_expected.to eq([[:diversity_disclosure]]) }
    end

    context "with multiple invalid?d diversity forms" do
      let(:trainee) { build(:trainee, :diversity_disclosed, :disabled) }

      it { is_expected.to eq([%i[ethnic_background ethnic_group disability_ids]]) }
    end
  end
end
