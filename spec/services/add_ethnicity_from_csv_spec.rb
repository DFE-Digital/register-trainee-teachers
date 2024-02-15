# frozen_string_literal: true

require "rails_helper"

RSpec.describe AddEthnicityFromCsv do
  let!(:provider) { create(:provider, code: "6B1") }
  let!(:trainee) { create(:trainee, provider:) }
  let!(:upload) { create(:upload, user: create(:user), name: "bpn-ethnicity.csv") }
  let(:ethnicity) { "Any other ethnic background: romanian" }
  let(:csv_content) { "trainee_id,ethnicity\n#{trainee.trainee_id},#{ethnicity}" }
  let(:service) { described_class.new(file_name: "bpn-ethnicity.csv", provider_code: "6B1") }

  before do
    csv_file = Tempfile.new(["test", ".csv"])
    csv_file.write(csv_content)
    csv_file.rewind

    upload.file.attach(
      io: File.open(csv_file.path),
      filename: "test.csv",
      content_type: "text/csv",
    )

    csv_file.close
    csv_file.unlink
  end

  it "updates the trainee with the correct ethnicity" do
    expect { service.call }.to change { trainee.reload.additional_ethnic_background }.from(nil).to("romanian")
    expect(trainee.ethnic_background).to eql "Another ethnic background"
    expect(trainee.ethnic_group).to eql "other_ethnic_group"
  end

  context "when the trainee does not exist" do
    let(:nonexistent_trainee_id) { "nonexistent_id" }
    let(:csv_content) { "trainee_id,ethnicity\n#{nonexistent_trainee_id},#{ethnicity}" }

    it "does not raise an error" do
      expect { service.call }.not_to raise_error
    end

    it "does not update any trainee" do
      expect { service.call }.not_to change(Trainee, :count)
    end
  end
end
