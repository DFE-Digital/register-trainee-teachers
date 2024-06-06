# frozen_string_literal: true

class SpecVersionGenerator
  include ServicePattern

  VERSION_FORMAT = /^v\d+\.\d+$/

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
    Dir.glob("spec/{models,requests,serializers}/api/#{convert_version_to_dir(old_version)}/**/*.rb")
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

    replacements = {
      old_version => new_version,                                                     # vx.x -> vy.y
      old_version.tr("v", "V") => new_version.tr("v", "V"),                           # Vx.x -> Vy.y
      old_version.tr(".", "_") => new_version.tr(".", "_"),                           # vx_x -> vy_y
      old_version.tr(".", "_").tr("v", "V") => new_version.tr(".", "_").tr("v", "V"), # Vx_x -> Vy_y
      old_version.tr(".", "") => new_version.tr(".", ""),                             # vxx -> vyy
      old_version.tr(".", "").upcase => new_version.tr(".", "").upcase, # Vxx -> Vyy
    }

    replacements.each do |old, new|
      new_content.gsub!(old, new)
    end

    new_content
  end

  def convert_version_to_dir(version)
    version.tr(".", "_")
  end
end
