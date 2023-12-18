# frozen_string_literal: true

require "rails_helper"
require Rails.root.join("db/data/20231214132713_add_ethnicity_to_teach_first_trainees")

describe AddEthnicityToTeachFirstTrainees::Service do
  let(:teach_first_provider) { create(:provider, :teach_first) }
  let(:trainee) { create(:trainee, provider: teach_first_provider) }
  let(:ethnicity) { "Any other ethnic background: romanian" }
  let(:service) { described_class.new }

  before do
    allow(service).to receive(:entries).and_return([[trainee.trainee_id, ethnicity]])
  end

  it "updates the trainee with the correct ethnicity" do
    expect { service.call }.to change { trainee.reload.additional_ethnic_background }.from(nil).to("romanian")
    expect(trainee.ethnic_background).to eql "Another ethnic background"
    expect(trainee.ethnic_group).to eql "other_ethnic_group"
  end

  context "when the trainee does not exist" do
    let(:nonexistent_trainee_id) { "nonexistent_id" }

    before do
      allow(service).to receive(:entries).and_return([[nonexistent_trainee_id, ethnicity]])
    end

    it "does not raise an error" do
      expect { service.call }.not_to raise_error
    end

    it "does not update any trainee" do
      expect { service.call }.not_to change(Trainee, :count)
    end
  end
end
