# frozen_string_literal: true

require "rails_helper"

describe Provider do
  describe "scopes" do
    describe ".with_active_hei" do
      let(:active_hei_provider) { create(:provider, :hei) }
      let(:inactive_hei_provider) { create(:provider, :hei) }
      let(:unaccredited_hei_provider) { create(:provider, :hei, :unaccredited) }
      let(:active_scitt_provider) { create(:provider, :scitt) }
      let(:inactive_scitt_provider) { create(:provider, :scitt) }
      let(:unaccredited_scitt_provider) { create(:provider, :scitt, :unaccredited) }

      before do
        active_hei_provider
        inactive_hei_provider.discard
        unaccredited_hei_provider
        active_scitt_provider
        inactive_scitt_provider.discard
        unaccredited_scitt_provider
      end

      it "returns providers that are accredited and have a valid accreditation_id" do
        expect(described_class.with_active_hei).to include(active_hei_provider)
        expect(described_class.with_active_hei).not_to include(inactive_hei_provider)
        expect(described_class.with_active_hei).not_to include(unaccredited_hei_provider)
        expect(described_class.with_active_hei).not_to include(active_scitt_provider)
        expect(described_class.with_active_hei).not_to include(inactive_scitt_provider)
        expect(described_class.with_active_hei).not_to include(unaccredited_scitt_provider)
      end
    end
  end

  context "fields" do
    it "validates presence" do
      expect(subject).to validate_presence_of(:name).with_message("Enter a provider name")
      expect(subject).to validate_presence_of(:ukprn).with_message("Enter a UKPRN in the correct format, like 12345678")
    end

    it "validates format" do
      subject.code = "abcd 1234"
      subject.ukprn = "3333"
      subject.valid?
      expect(subject.errors[:code]).to include("Enter a provider code in the correct format, like 12Y")
      expect(subject.errors[:ukprn]).to include("Enter a UKPRN in the correct format, like 12345678")
    end
  end

  context "validates dttp_id" do
    subject { create(:provider) }

    it "validates uniqueness" do
      expect(subject).to validate_uniqueness_of(:dttp_id).case_insensitive.with_message("Enter a unique DTTP ID")
    end
  end

  describe "indexes" do
    it { is_expected.to have_db_index(:dttp_id).unique(true) }
  end

  describe "associations" do
    it { is_expected.to have_many(:users) }
    it { is_expected.to have_many(:funding_payment_schedules) }
    it { is_expected.to have_many(:funding_trainee_summaries) }
    it { is_expected.to have_many(:recommendations_uploads) }
    it { is_expected.to have_many(:recommendations_upload_rows) }
    it { is_expected.to have_many(:sign_offs) }
  end

  describe "auditing" do
    it { is_expected.to be_audited }
    it { is_expected.to have_associated_audits }
  end

  describe "#hpitt_postgrad?" do
    subject { build(:provider, code:).hpitt_postgrad? }

    context "provider is a teach first provider" do
      let(:code) { Provider::TEACH_FIRST_PROVIDER_CODE }

      it { is_expected.to be_truthy }
    end

    context "provider is not a teach first provider" do
      let(:code) { Provider::TEACH_FIRST_PROVIDER_CODE.reverse }

      it { is_expected.to be_falsey }
    end
  end

  describe "#name_and_code" do
    subject { create(:provider, code: "B1T", name: "DfE University").name_and_code }

    it "returns name and code" do
      expect(subject).to eq("DfE University (B1T)")
    end
  end

  describe "code change" do
    let(:new_code) { "123" }
    let(:provider) { create(:provider, :with_courses) }

    it "changes the accredited_body_code for all the courses related to the provider" do
      provider.update(code: new_code)
      expect(provider.courses.pluck(:accredited_body_code)).to eq([new_code])
    end
  end

  describe "#without_required_placements" do
    let!(:this_cycle) { create(:academic_cycle, :current) }
    let!(:last_cycle) { create(:academic_cycle, previous_cycle: true) }
    let(:provider) { create(:provider) }
    let(:other_provider) { create(:provider) }
    let(:itt_start_date) { this_cycle.start_date }
    let(:itt_end_date) { this_cycle.end_date }
    let(:trainee) do
      create(
        :trainee, :provider_led_postgrad, :awarded, provider:, itt_start_date:, itt_end_date:
      )
    end
    let!(:other_provider_trainee) do
      create(
        :trainee,
        :provider_led_postgrad,
        :awarded,
        provider: other_provider,
        itt_start_date: itt_start_date,
        itt_end_date: itt_end_date,
      )
    end

    context "when the trainee is in the current cycle" do
      it "pulls the correct trainee(s) back" do
        expect(provider.without_required_placements).to contain_exactly(trainee)
      end

      it "does not find trainees for other providers" do
        expect(provider.without_required_placements).not_to include(other_provider_trainee)
      end
    end

    context "when the trainee is in the previous cycle" do
      let(:itt_start_date) { last_cycle.start_date }
      let(:itt_end_date) { last_cycle.end_date }

      it "pulls the correct trainee(s) back" do
        expect(provider.without_required_placements).to contain_exactly(trainee)
      end
    end

    context "when the trainee is from the distant past" do
      let(:old_cycle) do
        create(
          :academic_cycle,
          start_date: Date.new(2021, 8, 1),
          end_date: Date.new(2022, 7, 31),
        )
      end
      let(:itt_start_date) { old_cycle.start_date }
      let(:itt_end_date) { old_cycle.end_date }

      it "doesn't include the trainee" do
        expect(provider.without_required_placements).to be_empty
      end
    end

    context "when the trainee is in training" do
      let(:trainee) do
        create(
          :trainee, :provider_led_postgrad, :trn_received, provider:, itt_start_date:, itt_end_date:
        )
      end

      it "pulls the correct trainee(s) back" do
        expect(provider.without_required_placements).to contain_exactly(trainee)
      end
    end

    context "when the trainee is assessment-only" do
      let(:trainee) do
        create(
          :trainee,
          :trn_received,
          provider: provider,
          training_route: TRAINING_ROUTE_ENUMS[:assessment_only],
        )
      end

      it "doesn't include the trainee" do
        expect(provider.without_required_placements).to be_empty
      end
    end

    context "when the trainee is withdrawn" do
      let(:trainee) do
        create(
          :trainee,
          :withdrawn,
          provider: provider,
          training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad],
        )
      end

      it "doesn't include the trainee" do
        expect(provider.without_required_placements).to be_empty
      end
    end

    context "when the trainee already has one placement" do
      before do
        create(:placement, trainee:)
      end

      it "pulls the correct trainee(s) back" do
        expect(provider.without_required_placements).to contain_exactly(trainee)
      end
    end

    context "when the trainee already has two placements" do
      before do
        create(:placement, trainee:)
        create(:placement, trainee:)
      end

      it "doesn't include the trainee" do
        expect(provider.without_required_placements).to be_empty
      end
    end
  end

  describe "hei?" do
    context "when the accreditation_id begins with 1" do
      subject { build(:provider, accreditation_id: "123456").hei? }

      it { is_expected.to be true }
    end

    context "when the accreditation_id does not begin with 1" do
      subject { build(:provider, accreditation_id: "234567").hei? }

      it { is_expected.to be false }
    end
  end

  describe "#performance_profile_sign_offs" do
    context "when there are no sign offs" do
      let(:provider) { create(:provider) }

      it "returns an empty collection" do
        expect(provider.performance_profile_sign_offs).to be_empty
      end
    end

    context "when there are only census sign offs" do
      let(:provider) { create(:provider, :census_sign_off) }

      it "returns an empty collection" do
        expect(provider.performance_profile_sign_offs).to be_empty
      end
    end

    context "when there are census and performance sign offs" do
      let(:census_sign_off) { build(:sign_off, :census) }
      let(:performance_profile_sign_off) { build(:sign_off, :performance_profile) }
      let(:provider) { create(:provider, sign_offs: [performance_profile_sign_off, census_sign_off]) }

      it "returns only the performance sign offs" do
        expect(provider.performance_profile_sign_offs).to contain_exactly(performance_profile_sign_off)
      end
    end
  end

  describe "#performance_profile_signed_off?" do
    context "when there are no sign offs" do
      let(:provider) { create(:provider) }

      it "returns false" do
        expect(provider.performance_profile_signed_off?).to be false
      end
    end

    context "when there are only census sign offs" do
      let(:provider) { create(:provider, :census_sign_off) }

      it "returns false" do
        expect(provider.performance_profile_signed_off?).to be false
      end
    end

    context "when there are performance sign offs from the previous academic cycle" do
      let(:provider) { create(:provider, :previous_performance_profile_sign_off) }

      it "returns true" do
        expect(provider.performance_profile_signed_off?).to be true
      end
    end

    context "when there are performance sign offs from the current academic cycle" do
      let(:provider) { create(:provider, :performance_profile_sign_off) }

      it "returns false" do
        expect(provider.performance_profile_signed_off?).to be false
      end
    end
  end
end
