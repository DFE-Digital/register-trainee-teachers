require 'rails_helper'

RSpec.describe SpecVersionGenerator do
  let(:old_version) { 'v0.1' }
  let(:new_version) { 'v1.0' }
  let(:service) { described_class.call(old_version: old_version, new_version: new_version) }

  describe '#call' do
    let(:example_file) { 'spec/models/api/v0_1/trainee_attributes_spec.rb' }
    let(:new_file) { 'spec/models/api/v1_0/trainee_attributes_spec.rb' }
    let(:file_content) do
      <<~RUBY
        # frozen_string_literal: true

        require "rails_helper"

        RSpec.describe Api::V01::TraineeAttributes, type: :model do
          # ... code
        end
      RUBY
    end

    let(:request_file) { 'spec/requests/api/v0_1/get_trainee_spec.rb' }
    let(:new_request_file) { 'spec/requests/api/v1_0/get_trainee_spec.rb' }
    let(:request_file_content) do
      <<~RUBY
        # frozen_string_literal: true

        require "rails_helper"

        describe "`GET /api/v0.1/trainees/:id` endpoint" do
          # ... code
          context "when the trainee exists" do
            before { get("/api/v0.1/trainees/\#{trainee.slug}", headers: { Authorization: "Bearer \#{token}" }) }
            it "returns the trainee" do
              parsed_trainee = JSON.parse(Api::GetVersionedItem.for_serializer(model: :trainee, version: "v0.1").new(trainee).as_hash.to_json)
              expect(response.parsed_body).to eq(parsed_trainee)
            end
          end
        end
      RUBY
    end

    let(:serializer_file) { 'spec/serializers/api/v0_1/degree_serializer_spec.rb' }
    let(:new_serializer_file) { 'spec/serializers/api/v1_0/degree_serializer_spec.rb' }
    let(:serializer_file_content) do
      <<~RUBY
        # frozen_string_literal: true

        require "rails_helper"

        RSpec.describe Api::V01::DegreeSerializer do
          # ... code
          it "includes all expected fields" do
            expect(json.keys).to include("degree_id", "uk_degree")
          end
        end
      RUBY
    end

    before do
      allow(Dir).to receive(:glob).and_return([example_file, request_file, serializer_file])
      allow(File).to receive(:read).with(example_file).and_return(file_content)
      allow(File).to receive(:read).with(request_file).and_return(request_file_content)
      allow(File).to receive(:read).with(serializer_file).and_return(serializer_file_content)
      allow(FileUtils).to receive(:mkdir_p)
      allow(File).to receive(:write)
    end

    it 'creates the new directory for models' do
      expect(FileUtils).to receive(:mkdir_p).with('spec/models/api/v1_0')
      service
    end

    it 'creates the new directory for requests' do
      expect(FileUtils).to receive(:mkdir_p).with('spec/requests/api/v1_0')
      service
    end

    it 'creates the new directory for serializers' do
      expect(FileUtils).to receive(:mkdir_p).with('spec/serializers/api/v1_0')
      service
    end

    it 'writes the new file with updated version references' do
      expected_content = <<~RUBY
        # frozen_string_literal: true

        require "rails_helper"

        RSpec.describe Api::V10::TraineeAttributes, type: :model do
          # ... code
        end
      RUBY

      expect(File).to receive(:write).with(new_file, expected_content)
      service
    end

    it 'writes the new request file with updated version references' do
      expected_request_content = <<~RUBY
        # frozen_string_literal: true

        require "rails_helper"

        describe "`GET /api/v1.0/trainees/:id` endpoint" do
          # ... code
          context "when the trainee exists" do
            before { get("/api/v1.0/trainees/\#{trainee.slug}", headers: { Authorization: "Bearer \#{token}" }) }
            it "returns the trainee" do
              parsed_trainee = JSON.parse(Api::GetVersionedItem.for_serializer(model: :trainee, version: "v1.0").new(trainee).as_hash.to_json)
              expect(response.parsed_body).to eq(parsed_trainee)
            end
          end
        end
      RUBY

      expect(File).to receive(:write).with(new_request_file, expected_request_content)
      service
    end

    it 'writes the new serializer file with updated version references' do
      expected_serializer_content = <<~RUBY
        # frozen_string_literal: true

        require "rails_helper"

        RSpec.describe Api::V10::DegreeSerializer do
          # ... code
          it "includes all expected fields" do
            expect(json.keys).to include("degree_id", "uk_degree")
          end
        end
      RUBY

      expect(File).to receive(:write).with(new_serializer_file, expected_serializer_content)
      service
    end
  end
end
