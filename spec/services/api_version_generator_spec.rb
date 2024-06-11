# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApiVersionGenerator do
  let(:old_version) { "v0.1" }
  let(:new_version) { "v1.0" }
  let(:service) { described_class.call(old_version:, new_version:) }

  describe "#generate_new_version" do
    let(:example_file) { "app/models/api/v0_1/trainee_filter_params_attributes.rb" }
    let(:new_file) { "app/models/api/v1_0/trainee_filter_params_attributes.rb" }
    let(:file_content) do
      <<~RUBY
        # frozen_string_literal: true

        module Api
          module V01
            class TraineeFilterParamsAttributes
              # ... code
            end
          end
        end
      RUBY
    end

    let(:extra_module_file) { "app/services/api/v0_1/hesa_mapper/degree_attributes.rb" }
    let(:new_extra_module_file) { "app/services/api/v1_0/hesa_mapper/degree_attributes.rb" }
    let(:extra_module_file_content) do
      <<~RUBY
        # frozen_string_literal: true

        module Api
          module V01
            module HesaMapper
              class DegreeAttributes
                # ... code
              end
            end
          end
        end
      RUBY
    end

    before do
      allow(Dir).to receive(:glob).and_return([example_file, extra_module_file])
      allow(File).to receive(:readlines).with(example_file).and_return(file_content.lines)
      allow(File).to receive(:readlines).with(extra_module_file).and_return(extra_module_file_content.lines)
      allow(FileUtils).to receive(:mkdir_p)
      allow(File).to receive(:write)
    end

    it "creates the new directory" do
      expect(FileUtils).to receive(:mkdir_p).with("app/models/api/v1_0")
      expect(FileUtils).to receive(:mkdir_p).with("app/services/api/v1_0/hesa_mapper")
      service
    end

    it "writes the new file with updated module and class" do
      expected_content = <<~RUBY
        # frozen_string_literal: true

        module Api
          module V10
            class TraineeFilterParamsAttributes < Api::V01::TraineeFilterParamsAttributes
            end
          end
        end
      RUBY

      expect(File).to receive(:write).with(new_file, expected_content)
      service
    end

    it "writes the new file with updated module and class for files with extra modules" do
      expected_extra_module_content = <<~RUBY
        # frozen_string_literal: true

        module Api
          module V10
            module HesaMapper
              class DegreeAttributes < Api::V01::HesaMapper::DegreeAttributes
              end
            end
          end
        end
      RUBY

      expect(File).to receive(:write).with(new_extra_module_file, expected_extra_module_content)
      service
    end
  end
end
