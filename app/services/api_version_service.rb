# frozen_string_literal: true

class ApiVersionService
  include ServicePattern

  VERSION_FORMAT = /^v\d+\.\d+(-pre|-rc)?$/

  def initialize(old_version:, new_version:)
    validate_version_format(old_version)
    validate_version_format(new_version)

    @old_version = convert_version_format(old_version)
    @new_version = convert_version_format(new_version)
  end

private

  attr_reader :old_version, :new_version

  def validate_version_format(version)
    raise(ArgumentError, "Version format is incorrect. Expected format: vx.x") unless version.match?(VERSION_FORMAT)
  end

  def convert_version_format(version)
    version.tr(".", "_").tr("-", "_")
  end

  def files
    Dir.glob("app/{models,serializers,services,validators}/api/#{old_version}/**/*.rb")
  end

  def new_file_path(file)
    file.gsub("/#{old_version}/", "/#{new_version}/")
  end

  def create_new_directory(new_file)
    new_dir = File.dirname(new_file)
    FileUtils.mkdir_p(new_dir)
  end

  def generate_new_class_content(file)
    module_lines, class_line = extract_module_and_class_lines(file)
    module_declarations = transform_module_lines(module_lines)
    class_name, parent_class = extract_class_name_and_parent_class(class_line, file)

    generate_content(module_declarations, class_name, parent_class, module_lines)
  end

  def extract_module_and_class_lines(file)
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

    [module_lines, class_line]
  end

  def transform_module_lines(module_lines)
    module_lines.grep_v(/^#\s*frozen_string_literal/)
                .map { |line| line.sub(old_version.camelize, new_version.camelize) }
                .join("\n")
                .strip
  end

  def extract_class_name_and_parent_class(class_line, file)
    relative_path = file.gsub(%r{app/(models|serializers|services)/api/#{old_version}/}, "").gsub(".rb", "")
    module_path = relative_path.split("/").map(&:camelize).join("::")
    parent_class = "Api::#{old_version.camelize}::#{module_path}"
    class_name = class_line.split[1]

    [class_name, parent_class]
  end

  def generate_content(module_declarations, class_name, parent_class, module_lines)
    last_module_indent = module_lines.last[/^\s*/]
    class_indent = "#{last_module_indent}  "
    module_indents = module_lines.map { |line| line[/^\s*/] }.uniq
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
