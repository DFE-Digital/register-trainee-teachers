# app/services/api_version_generator.rb

class ApiVersionGenerator
  def initialize(old_version:, new_version:)
    @old_version = old_version
    @new_version = new_version
  end

  def generate_new_version
    files.each do |file|
      new_file = new_file_path(file)
      create_new_directory(new_file)
      new_class_content = generate_new_class_content(file)
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

  def generate_new_class_content(file)
    content_lines = File.readlines(file).map(&:chomp)
    module_lines = []
    class_line = nil
    capture_lines = true

    content_lines.each do |line|
      if line =~ /^\s*class\s+/
        class_line = line
        capture_lines = false
      end
      module_lines << line if capture_lines
    end

    module_lines.reject! { |line| line =~ /^#\s*frozen_string_literal/ }
    module_lines.map! { |line| line.sub(old_version.camelize, new_version.camelize) }

    relative_path = file.gsub(%r{app/(models|serializers|services)/api/#{old_version}/}, '').gsub('.rb', '')
    module_path = relative_path.split('/').map(&:camelize).join('::')
    parent_class = "Api::#{old_version.camelize}::#{module_path}"
    class_name = class_line.split[1]

    module_declarations = module_lines.join("\n").strip
    module_indents = module_lines.map { |line| line[/^\s*/] }.uniq
    last_module_indent = module_lines.last[/^\s*/]
    class_indent = last_module_indent + '  '

    indented_endings = module_indents.reverse.map { |indent| "#{indent}end" }.join("\n")

    <<~RUBY
      # frozen_string_literal: true

      #{module_declarations}
      #{class_indent}class #{class_name} < #{parent_class}
      #{class_indent}end
      #{indented_endings}
    RUBY
  end
end
