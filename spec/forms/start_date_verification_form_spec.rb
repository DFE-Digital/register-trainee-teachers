# frozen_string_literal: true

require "rails_helper"

describe StartDateVerificationForm, type: :model do
  let(:trainee) { create(:trainee, :deferred) }
  let(:form_store) { class_double(FormStore) }
  let(:trainee_has_started_course) { "yes" }

  let(:params) do
    {
      trainee_has_started_course: trainee_has_started_course,
    }
  end

  subject { described_class.new(trainee, params: params.stringify_keys, store: form_store) }

  before do
    allow(form_store).to receive(:get).and_return(nil)
  end

  describe "validations" do
    context "trainee_has_started_course" do
      let(:trainee_has_started_course) { nil }

      context "when not provided" do
        it { is_expected.to validate_presence_of(:trainee_has_started_course) }
        it { is_expected.to validate_inclusion_of(:trainee_has_started_course).in_array(%w[yes no]) }
      end
    end
  end

  describe "#save!" do
    let(:trainee_has_started_course) { "no" }

    it "takes any data from the form store and saves it to the database and clears the store data" do
      expect(form_store).to receive(:set).with(trainee.id, :start_date_verification, nil)

      expect { subject.save! }.to change(trainee, :commencement_status).to("itt_not_yet_started")
    end
  end
end
