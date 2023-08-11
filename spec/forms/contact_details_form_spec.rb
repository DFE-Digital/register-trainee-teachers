# frozen_string_literal: true

require "rails_helper"

describe ContactDetailsForm, type: :model do
  let(:params) { {} }
  let(:trainee) { build(:trainee) }
  let(:form_store) { class_double(FormStore) }

  subject { described_class.new(trainee, params: params, store: form_store) }

  before do
    allow(form_store).to receive(:get).and_return(nil)
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:email) }

    context "empty form data" do
      let(:params) do
        {
          "email" => "",
        }
      end

      before do
        subject.valid?
      end

      it "returns 1 error about email" do
        expect(subject.errors.attribute_names).to match(%i[email])
      end
    end
  end

  describe "#stash" do
    let(:trainee) { create(:trainee) }

    it "uses FormStore to temporarily save the fields under a key combination of trainee ID and contact_details" do
      expect(form_store).to receive(:set).with(trainee.id, :contact_details, subject.fields)

      subject.stash
    end
  end

  describe "#save!" do
    let(:params) { {} }
    let(:trainee) { create(:trainee) }

    before do
      allow(form_store).to receive(:get).and_return({
        "email" => "test @example.com",
      })
      allow(form_store).to receive(:set).with(trainee.id, :contact_details, nil)
    end

    it "strips all whitespace from emails" do
      expect { subject.save! }.to change(trainee, :email).to("test@example.com")
    end
  end
end
