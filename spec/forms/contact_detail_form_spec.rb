# frozen_string_literal: true

require "rails_helper"

describe ContactDetailForm, type: :model do
  let(:trainee) { build(:trainee) }

  subject { described_class.new(trainee) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:locale_code) }
    it { is_expected.to validate_presence_of(:email) }

    context "international address validations" do
      before do
        trainee.locale_code = "non_uk"
        subject.valid?
      end

      it "returns an error if its empty" do
        expect(subject.errors[:international_address]).to include(
          I18n.t(
            "activemodel.errors.models.contact_detail_form.attributes.international_address.blank",
          ),
        )
      end
    end

    context "UK address fields validations" do
      before do
        trainee.locale_code = "uk"
        trainee.address_line_one = nil
        trainee.address_line_two = nil
        trainee.town_city = nil
        trainee.postcode = nil
        subject.valid?
      end

      it "returns an error if its empty" do
        %w[ address_line_one
            town_city
            postcode].each do |field|
          expect(subject.errors[field.to_sym])
            .to include(I18n.t("activemodel.errors.models.contact_detail_form.attributes.#{field}.blank"))
        end
      end

      it "returns no error for address_line_two because it is optional" do
        expect(subject.errors[:address_line_two])
          .to be_empty
      end
    end
  end

  describe "formatting emails" do
    it "strips whitespace from emails" do
      trainee.email = "test @example.com"
      subject.save # rubocop:disable Rails/SaveBang
      expect(trainee.email).to eq("test@example.com")
    end
  end
end
