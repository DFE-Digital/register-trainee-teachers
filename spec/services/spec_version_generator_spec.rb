# frozen_string_literal: true

require "rails_helper"

RSpec.describe SpecVersionGenerator do
  let(:old_version) { "v2025.0-rc" }
  let(:new_version) { "v2026.0-rc" }
  let(:service) { described_class.call(old_version:, new_version:) }

  describe "#call" do
    let(:request_file) { "spec/requests/api/v2025_0_rc/get_trainee_spec.rb" }
    let(:new_request_file) { "spec/requests/api/v2026_0_rc/get_trainee_spec.rb" }
    let(:request_file_content) do
      <<~RUBY
        # frozen_string_literal: true

        require "rails_helper"

        describe "`GET /api/v2025.0-rc/trainees/:id` endpoint" do
          # ... code
          context "when the trainee exists" do
            before { get("/api/v2025.0-rc/trainees/\#{trainee.slug}", headers: { Authorization: "Bearer \#{token}" }) }
            it "returns the trainee" do
              parsed_trainee = JSON.parse(Api::GetVersionedItem.for_serializer(model: :trainee, version: "v2025.0-rc").new(trainee).as_hash.to_json)
              expect(response.parsed_body).to eq(parsed_trainee)
            end

            describe Api::V20250Rc::TraneeService do
              # ... code
            end
          end
        end
      RUBY
    end

    before do
      allow(Dir).to receive(:glob).and_return([request_file])
      allow(File).to receive(:read).with(request_file).and_return(request_file_content)
      allow(FileUtils).to receive(:mkdir_p)
      allow(File).to receive(:write)
    end

    it "creates the new directory for requests" do
      expect(FileUtils).to receive(:mkdir_p).with("spec/requests/api/v2026_0_rc")
      service
    end

    it "writes the new request file with updated version references" do
      expected_request_content = <<~RUBY
        # frozen_string_literal: true

        require "rails_helper"

        describe "`GET /api/v2026.0-rc/trainees/:id` endpoint" do
          # ... code
          context "when the trainee exists" do
            before { get("/api/v2026.0-rc/trainees/\#{trainee.slug}", headers: { Authorization: "Bearer \#{token}" }) }
            it "returns the trainee" do
              parsed_trainee = JSON.parse(Api::GetVersionedItem.for_serializer(model: :trainee, version: "v2026.0-rc").new(trainee).as_hash.to_json)
              expect(response.parsed_body).to eq(parsed_trainee)
            end

            describe Api::V20260Rc::TraneeService do
              # ... code
            end
          end
        end
      RUBY

      expect(File).to receive(:write).with(new_request_file, expected_request_content)
      service
    end
  end
end
