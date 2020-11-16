require "rails_helper"

describe ContactDetail do
  let(:trainee) { build(:trainee) }

  subject { described_class.new(trainee: trainee) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:locale_code) }
    it { is_expected.to validate_presence_of(:phone_number) }
    it { is_expected.to validate_presence_of(:email) }

    context "international address validations" do
      before do
        trainee.locale_code = "non_uk"
        subject.valid?
      end

      it "returns an error if its empty" do
        expect(subject.errors[:international_address]).to include(
          I18n.t(
            "activemodel.errors.models.contact_detail.attributes.international_address.blank",
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
            .to include(I18n.t("activemodel.errors.models.contact_detail.attributes.#{field}.blank"))
        end
      end

      it "returns no error for address_line_two because it is optional" do
        expect(subject.errors[:address_line_two])
          .to be_empty
      end
    end

    describe "email" do
      it "must fail if only @" do
        trainee.email = "@"
        expect(subject).not_to be_valid
        expect(subject.errors[:email])
          .to include(I18n.t("activemodel.errors.models.contact_detail.attributes.email.invalid"))
      end

      it "must fail if it does not contain @" do
        trainee.email = "myname.com"
        expect(subject).not_to be_valid
        expect(subject.errors[:email])
          .to include(I18n.t("activemodel.errors.models.contact_detail.attributes.email.invalid"))
      end

      it "accepts a valid email address" do
        trainee.email = "my_name@doman.com"
        expect(subject).to be_valid
      end
    end
  end
end
