# frozen_string_literal: true

class SpecVersionGenerator
  include ServicePattern

  VERSION_FORMAT = /^v\d+\.\d+(-\w+)?$/

  def initialize(old_version:, new_version:)
    validate_version_format(old_version)
    validate_version_format(new_version)

    @old_version = old_version
    @new_version = new_version
  end

  def call
    spec_files.each do |file|
      new_file = new_file_path(file)
      create_new_directory(new_file)
      new_spec_content = generate_new_spec_content(File.read(file))
      File.write(new_file, new_spec_content)
    end
  end

private

  attr_reader :old_version, :new_version

  def validate_version_format(version)
    raise(ArgumentError, "Version format is incorrect. Expected format: vx.x") unless version.match?(VERSION_FORMAT)
  end

  def spec_files
    Dir.glob("spec/requests/api/#{convert_version_to_dir(old_version)}/**/*.rb")
  end

  def new_file_path(file)
    file.gsub("/#{convert_version_to_dir(old_version)}/", "/#{convert_version_to_dir(new_version)}/")
  end

  def create_new_directory(new_file)
    new_dir = File.dirname(new_file)
    FileUtils.mkdir_p(new_dir)
  end

  def generate_new_spec_content(content)
    new_content = content.dup

    # Create version formats for different use cases
    old_version_for_class = old_version.tr(".", "").gsub(/-(\w)/) { ::Regexp.last_match(1).upcase }.tr("v", "V") # v2025.0-rc -> V20250Rc
    new_version_for_class = new_version.tr(".", "").gsub(/-(\w)/) { ::Regexp.last_match(1).upcase }.tr("v", "V") # v2026.0-rc -> V20260Rc

    replacements = {
      old_version => new_version,                                                              # v2025.0-rc -> v2026.0-rc
      old_version.tr("v", "V") => new_version.tr("v", "V"),                                    # V2025.0-rc -> V2026.0-rc
      convert_version_to_dir(old_version) => convert_version_to_dir(new_version),              # v2025_0_rc -> v2026_0_rc
      convert_version_to_dir(old_version).tr("v", "V") => convert_version_to_dir(new_version).tr("v", "V"), # V2025_0_rc -> V2026_0_rc
      old_version_for_class => new_version_for_class, # V20250Rc -> V20260Rc
    }

    replacements.each do |old, new|
      new_content.gsub!(old, new)
    end

    new_content
  end

  def convert_version_to_dir(version)
    version.tr(".-", "_")
  end
end
