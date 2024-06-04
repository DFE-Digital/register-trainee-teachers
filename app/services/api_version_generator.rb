# frozen_string_literal: true

class ApiVersionGenerator
  def initialize(old_version:, new_version:)
    @old_version = old_version
    @new_version = new_version
  end

  def generate_new_version
    files.each do |file|
      new_file = new_file_path(file)
      create_new_directory(new_file)
      new_class_content = update_class_content(file)
      File.write(new_file, new_class_content)
    end
  end

  private

  attr_reader :old_version, :new_version

  def files
    Dir.glob("app/{models,serializers,services}/api/#{old_version}/**/*.rb")
  end

  def new_file_path(file)
    file.gsub("/#{old_version}/", "/#{new_version}/")
  end

  def create_new_directory(new_file)
    new_dir = File.dirname(new_file)
    FileUtils.mkdir_p(new_dir) unless Dir.exist?(new_dir)
  end

  def update_class_content(file)
    content_lines = File.readlines(file)
    new_class_content = content_lines.map do |line|
      if line =~ /^\s*module\s+#{old_version.camelize}/
        line.sub(old_version.camelize, new_version.camelize)
      else
        line
      end
    end.join

    relative_path = file.gsub(%r{app/(models|serializers|services)/api/#{old_version}/}, '').gsub('.rb', '')
    module_path = relative_path.split('/').map(&:camelize).join('::')
    parent_class = "Api::#{old_version.camelize}::#{module_path}"

    new_class_content.sub!(/class (\w+)/) do |match|
      class_name = Regexp.last_match(1)
      "class #{class_name} < #{parent_class}"
    end

    new_class_content
  end
end
